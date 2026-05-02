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
        CommandSpec::Args(args) => args.join(" "),
        CommandSpec::Shell(command) => command.clone(),
    }
}

fn run_command(command: &CommandSpec) -> io::Result<std::process::ExitStatus> {
    match command {
        CommandSpec::Args(args) => {
            let (program, rest) = args.split_first().ok_or_else(|| {
                io::Error::new(io::ErrorKind::InvalidInput, "empty command argv")
            })?;
            Command::new(program).args(rest).status()
        }
        CommandSpec::Shell(command) => Command::new("sh").arg("-c").arg(command).status(),
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
                println!(
                    "{} precheck failed with: {precheck_code}",
                    entry.prompt
                );
                status_map
                    .lock()
                    .unwrap()
                    .insert(entry.prompt.clone(), Some(precheck_code));
                continue;
            }
        }

        println!("Executing: {}", entry.prompt);
        println!("Command: {}", command_text(&entry.command));
        let status = run_command(&entry.command);

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
