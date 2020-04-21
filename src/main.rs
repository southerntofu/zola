use std::env;
use std::path::PathBuf;
use std::time::Instant;

mod cli;
mod cmd;
mod console;
mod prompt;

fn main() {
    let matches = cli::build_cli().get_matches();

    let root_dir = match matches.value_of("root").unwrap() {
        "." => env::current_dir().unwrap(),
        path => PathBuf::from(path),
    };
    let config_file = matches.value_of("config").unwrap();

    match matches.subcommand() {
        ("init", Some(matches)) => {
            match cmd::create_new_project(matches.value_of("name").unwrap()) {
                Ok(()) => (),
                Err(e) => {
                    console::unravel_errors("Failed to create the project", &e);
                    ::std::process::exit(1);
                }
            };
        }
        ("build", Some(matches)) => {
            console::info("Building site...");
            let start = Instant::now();
            let output_dir = matches.value_of("output_dir").unwrap();
            match cmd::build(
                &root_dir,
                config_file,
                matches.value_of("base_url"),
                output_dir,
                matches.is_present("drafts"),
            ) {
                Ok(()) => console::report_elapsed_time(start),
                Err(e) => {
                    console::unravel_errors("Failed to build the site", &e);
                    ::std::process::exit(1);
                }
            };
        }
        ("check", Some(matches)) => {
            console::info("Checking site...");
            let start = Instant::now();
            match cmd::check(
                &root_dir,
                config_file,
                matches.value_of("base_path"),
                matches.value_of("base_url"),
                matches.is_present("drafts"),
            ) {
                Ok(()) => console::report_elapsed_time(start),
                Err(e) => {
                    console::unravel_errors("Failed to check the site", &e);
                    ::std::process::exit(1);
                }
            };
        }
        _ => unreachable!(),
    }
}
