#!/usr/bin/env nix-shell
//! ```cargo
//! [features]
//! default = []
//!
//! [dependencies]
//! rayon = "1.10.0"
//! toml = "0.8"
//! serde = { version = "1.0", features = ["derive"] }
//! ctrlc = "3.4"
//! ```
/*
#!nix-shell -i rust-script -p rustc -p rust-script -p cargo -p rustfmt -p git -p nix -p pkg-config -p openssl.dev
*/

use rayon::prelude::*;
use serde::Deserialize;
use std::{
    collections::HashMap,
    env, fs,
    io::{self, Write},
    process::Command,
    sync::{Arc, Mutex},
    thread,
    time::Duration,
};

#[derive(Deserialize)]
struct CommandEntry {
    prompt: String,
    command: String,
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

fn main() {
    // Cache sudo
    let _ = Command::new("sudo")
        .arg("-v")
        .status()
        .expect("sudo -v failed");
    keep_sudo_alive();

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
        let _ = Command::new("nix-store")
            .args(["--add-fixed", "sha256", "baserom.us.z64"])
            .status();
    }

    // Load commands
    let config_str = fs::read_to_string("commands.toml").expect("failed to read commands.toml");
    let config: Config = toml::from_str(&config_str).expect("invalid TOML format");

    let selected: Vec<_> = config
        .commands
        .into_iter()
        .filter_map(|entry| {
            if confirm(&entry.prompt) {
                Some((entry.prompt, entry.command))
            } else {
                println!("Skipped: {}", entry.command);
                None
            }
        })
        .collect();

    // Shared status map
    let status_map: Arc<Mutex<HashMap<String, Option<i32>>>> = Arc::new(Mutex::new(
        selected.iter().map(|(p, _)| (p.clone(), None)).collect(),
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

    // Run in parallel
    selected.par_iter().for_each(|(label, cmd)| {
        println!("Executing: {label}");
        let status = Command::new("sh").arg("-c").arg(cmd).status();

        let code = status.map(|s| s.code().unwrap_or(-1)).unwrap_or(-1);
        status_map.lock().unwrap().insert(label.clone(), Some(code));
        println!("{label} exited with: {code}");
    });

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
