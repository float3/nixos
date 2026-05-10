#!/usr/bin/env nix-shell
//! ```cargo
//! [features]
//! default = []
//!
//! [dependencies]
//! toml = "0.8"
//! serde = { version = "1.0", features = ["derive"] }
//! ctrlc = "3.4"
//! ```
/*
#!nix-shell -i rust-script -p rustc -p rust-script -p cargo -p rustfmt -p git -p nix -p pkg-config -p openssl.dev
*/

use serde::Deserialize;
use std::{
    collections::HashMap,
    env, fs,
    io::{self, Write},
    path::Path,
    process::Command,
    sync::{Arc, Mutex},
    thread,
    time::Duration,
};

#[derive(Clone, Deserialize)]
struct CommandEntry {
    prompt: String,
    command: CommandSpec,
    precheck: Option<CommandSpec>,
    needs_sudo: Option<bool>,
}

#[derive(Clone, Deserialize)]
#[serde(untagged)]
enum CommandSpec {
    Args(Vec<String>),
    Shell(String),
}

#[derive(Deserialize)]
struct Config {
    commands: Vec<CommandEntry>,
}

#[derive(Default)]
struct CliOptions {
    extra_nix_args: Vec<String>,
}

fn confirm(prompt: &str) -> bool {
    print!("{prompt} (Y/N): ");
    io::stdout().flush().unwrap();
    let mut input = String::new();
    if io::stdin().read_line(&mut input).is_ok() {
        matches!(input.trim().to_lowercase().as_str(), "y" | "yes")
    } else {
        false
    }
}

fn usage(program: &str) {
    println!(
        "\
Usage: {program} [OPTIONS] [-- EXTRA_NIX_ARGS...]

Adds build-control arguments to nix/nixos-rebuild commands loaded from commands.toml.

Options:
  --max-jobs <N>          Limit concurrent Nix build jobs
  --cores <N>             Limit cores visible to each build job
  --builders <SPEC>       Set builders, use an empty value to disable remote builders
  --no-write-lock-file    Evaluate flakes without updating flake.lock
  --print-build-logs      Print build logs while running
  --extra-nix-arg <ARG>   Append one raw argument to nix/nixos-rebuild commands
  -h, --help              Show this help

Examples:
  {program} --max-jobs 1 --cores 1 --builders ''
  {program} --max-jobs=1 --cores=1 --builders=
  {program} --max-jobs 1 --cores 1 -- --option sandbox true"
    );
}

fn parse_cli_args() -> CliOptions {
    let program = env::args()
        .next()
        .unwrap_or_else(|| "deploy.rs".to_string());
    let mut args = env::args().skip(1);
    let mut options = CliOptions::default();

    while let Some(arg) = args.next() {
        match arg.as_str() {
            "-h" | "--help" => {
                usage(&program);
                std::process::exit(0);
            }
            "--" => {
                options.extra_nix_args.extend(args);
                break;
            }
            "--max-jobs" | "--cores" | "--builders" => {
                let value = args.next().unwrap_or_else(|| {
                    eprintln!("{arg} requires a value");
                    std::process::exit(2);
                });
                options.extra_nix_args.push(arg);
                options.extra_nix_args.push(value);
            }
            "--no-write-lock-file" | "--print-build-logs" => {
                options.extra_nix_args.push(arg);
            }
            "--extra-nix-arg" => {
                let value = args.next().unwrap_or_else(|| {
                    eprintln!("{arg} requires a value");
                    std::process::exit(2);
                });
                options.extra_nix_args.push(value);
            }
            _ if arg.starts_with("--max-jobs=") => {
                push_split_arg(&mut options.extra_nix_args, "--max-jobs", &arg);
            }
            _ if arg.starts_with("--cores=") => {
                push_split_arg(&mut options.extra_nix_args, "--cores", &arg);
            }
            _ if arg.starts_with("--builders=") => {
                push_split_arg(&mut options.extra_nix_args, "--builders", &arg);
            }
            _ => {
                eprintln!("unknown argument: {arg}");
                eprintln!("Run {program} --help for usage.");
                std::process::exit(2);
            }
        }
    }

    options
}

fn push_split_arg(extra_nix_args: &mut Vec<String>, option: &str, arg: &str) {
    let value = arg
        .split_once('=')
        .map(|(_, value)| value)
        .expect("caller checked for '='");
    extra_nix_args.push(option.to_string());
    extra_nix_args.push(value.to_string());
}

fn keep_sudo_alive() {
    thread::spawn(|| loop {
        thread::sleep(Duration::from_secs(60));
        let _ = Command::new("sudo").arg("-v").status();
    });
}

fn sudo_refresh() {
    let status = Command::new("sudo")
        .arg("-v")
        .status()
        .expect("failed to run sudo -v");

    if !status.success() {
        eprintln!("sudo authentication failed");
        std::process::exit(status.code().unwrap_or(1));
    }
}

fn command_text(command: &CommandSpec) -> String {
    match command {
        CommandSpec::Args(args) => args
            .iter()
            .map(|arg| display_arg(arg))
            .collect::<Vec<_>>()
            .join(" "),
        CommandSpec::Shell(command) => command.clone(),
    }
}

fn display_arg(arg: &str) -> String {
    if arg.is_empty() {
        return "''".to_string();
    }

    if arg.chars().all(|ch| {
        ch.is_ascii_alphanumeric() || matches!(ch, '_' | '-' | '.' | '/' | ':' | '#' | '=' | '@')
    }) {
        arg.to_string()
    } else {
        format!("'{}'", arg.replace('\'', "'\\''"))
    }
}

fn run_command(command: &CommandSpec) -> io::Result<std::process::ExitStatus> {
    match command {
        CommandSpec::Args(args) => {
            let (program, rest) = args
                .split_first()
                .ok_or_else(|| io::Error::new(io::ErrorKind::InvalidInput, "empty command argv"))?;
            Command::new(program).args(rest).status()
        }
        CommandSpec::Shell(command) => Command::new("sh").arg("-c").arg(command).status(),
    }
}

fn with_extra_nix_args(command: &CommandSpec, extra_nix_args: &[String]) -> CommandSpec {
    if extra_nix_args.is_empty() {
        return command.clone();
    }

    match command {
        CommandSpec::Args(args) if accepts_nix_args(args) => {
            let mut args = args.clone();
            args.extend(extra_nix_args.iter().cloned());
            CommandSpec::Args(args)
        }
        _ => command.clone(),
    }
}

fn accepts_nix_args(args: &[String]) -> bool {
    match args.first().map(String::as_str) {
        Some("nix" | "nixos-rebuild") => true,
        Some("sudo") => args
            .get(1)
            .is_some_and(|program| matches!(program.as_str(), "nix" | "nixos-rebuild")),
        _ => false,
    }
}

fn command_needs_sudo(entry: &CommandEntry) -> bool {
    if let Some(needs_sudo) = entry.needs_sudo {
        return needs_sudo;
    }

    match &entry.command {
        CommandSpec::Args(args) => args.first().is_some_and(|program| program == "sudo"),
        CommandSpec::Shell(command) => command.split_whitespace().next() == Some("sudo"),
    }
}

fn main() {
    let cli_options = parse_cli_args();

    // Host-specific logic
    let hostname = env::var("HOSTNAME").unwrap_or_else(|_| {
        String::from_utf8(
            Command::new("hostname")
                .output()
                .expect("failed to run hostname")
                .stdout,
        )
        .unwrap()
        .trim()
        .to_string()
    });

    if matches!(hostname.as_str(), "workstation" | "laptop" | "steamdeck") {
        let baserom = Path::new("baserom.us.z64");
        if baserom.exists() {
            let _ = Command::new("nix-store")
                .args(["--add-fixed", "sha256", "baserom.us.z64"])
                .status();
        } else {
            eprintln!("Skipping baserom.us.z64 import: file not found.");
        }
    }

    // Load commands
    let config_str = fs::read_to_string("commands.toml").expect("failed to read commands.toml");
    let config: Config = toml::from_str(&config_str).expect("invalid TOML format");

    if !cli_options.extra_nix_args.is_empty() {
        let extra_args = cli_options
            .extra_nix_args
            .iter()
            .map(|arg| display_arg(arg))
            .collect::<Vec<_>>()
            .join(" ");
        println!("Extra Nix args: {extra_args}");
    }

    let selected: Vec<_> = config
        .commands
        .into_iter()
        .filter_map(|entry| {
            if confirm(&entry.prompt) {
                Some(entry)
            } else {
                println!("Skipped: {}", command_text(&entry.command));
                None
            }
        })
        .collect();

    if selected.iter().any(command_needs_sudo) {
        sudo_refresh();
        keep_sudo_alive();
    }

    // Shared status map
    let status_map: Arc<Mutex<HashMap<String, Option<i32>>>> = Arc::new(Mutex::new(
        selected
            .iter()
            .map(|entry| (entry.prompt.clone(), None))
            .collect(),
    ));

    // Ctrl+C handler
    {
        let map = Arc::clone(&status_map);
        ctrlc::set_handler(move || {
            println!("\nInterrupted! Reporting partial results...\n");
            report_status(&map);
            std::process::exit(130);
        })
        .expect("Failed to set Ctrl+C handler");
    }

    for entry in selected {
        if let Some(precheck) = &entry.precheck {
            println!("Precheck: {}", command_text(precheck));
            let precheck_code = run_command(precheck)
                .map(|status| status.code().unwrap_or(-1))
                .unwrap_or(-1);
            if precheck_code != 0 {
                println!("{} precheck failed with: {precheck_code}", entry.prompt);
                status_map
                    .lock()
                    .unwrap()
                    .insert(entry.prompt.clone(), Some(precheck_code));
                continue;
            }
        }

        println!("Executing: {}", entry.prompt);
        let command = with_extra_nix_args(&entry.command, &cli_options.extra_nix_args);
        println!("Command: {}", command_text(&command));
        let status = run_command(&command);

        let code = status.map(|s| s.code().unwrap_or(-1)).unwrap_or(-1);
        status_map
            .lock()
            .unwrap()
            .insert(entry.prompt.clone(), Some(code));
        println!("{} exited with: {code}", entry.prompt);
    }

    // Final report
    println!("\nAll done. Summary:");
    report_status(&status_map);
}

fn report_status(map: &Arc<Mutex<HashMap<String, Option<i32>>>>) {
    for (label, code_opt) in map.lock().unwrap().iter() {
        match code_opt {
            Some(0) => println!("[OK]     {label}"),
            Some(c) => println!("[FAILED] {label} (exit code {c})"),
            None => println!("[SKIPPED/INTERRUPTED] {label}"),
        }
    }
}
