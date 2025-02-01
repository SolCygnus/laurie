#!/usr/bin/env python3

# Author: SillyPenguin
# Date: 29 Jan 25
# Purpose: Main.py to install necessary packages (bash scripts) and custom build Linux Mint for open-source research

import subprocess
import logging
import os

# Define log file
LOG_FILE = os.path.join(os.path.dirname(__file__), "laurie_repo.log")
SCRIPTS_DIR = os.path.join(os.path.dirname(__file__), "scripts")

# Ensure the log file exists and has the correct permissions
try:
    if not os.path.exists(LOG_FILE):
        with open(LOG_FILE, "w"):  # Create an empty log file if it doesn’t exist
            pass
    os.chmod(LOG_FILE, 0o666)  # Ensure the log file is writable by all users
except Exception as e:
    print(f"❌ Failed to set up logging file: {e}")
    exit(1)

# Configure logging
logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)

def make_scripts_executable():
    """Ensure all scripts in the scripts directory are executable."""
    if not os.path.exists(SCRIPTS_DIR):
        logging.error(f"Scripts directory not found: {SCRIPTS_DIR}")
        print(f"❌ Scripts directory not found: {SCRIPTS_DIR}")
        exit(1)

    for script in os.listdir(SCRIPTS_DIR):
        script_path = os.path.join(SCRIPTS_DIR, script)
        if os.path.isfile(script_path):
            try:
                os.chmod(script_path, 0o755)
                logging.info(f"Made executable: {script}")
            except Exception as e:
                logging.error(f"Failed to make {script} executable: {e}")
                print(f"❌ Failed to make {script} executable: {e}")

def run_bash_script(script_name):
    """Runs a given bash script and consolidates its output into the main log while also displaying it in real-time."""
    script_path = os.path.join(SCRIPTS_DIR, script_name)

    if not os.path.exists(script_path):
        logging.error(f"Script not found: {script_name}")
        print(f"Error: {script_name} not found.")
        return

    try:
        logging.info(f"Starting script: {script_name}")
        print(f"Executing: {script_name}...")

        with open(LOG_FILE, "a") as log_file:
            process = subprocess.Popen(["bash", script_path], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
            for line in process.stdout:
                print(line, end="")  # Print to console
                log_file.write(line)  # Write to log file
                log_file.flush()
            process.wait()

        if process.returncode == 0:
            logging.info(f"✅ Script {script_name} executed successfully.")
            print(f"✔ {script_name} executed successfully.")
        else:
            logging.error(f"❌ Script {script_name} failed with return code {process.returncode}.")
            print(f"❌ {script_name} failed. Check logs.")
    except Exception as e:
        logging.error(f"❌ Error running {script_name}: {e}")
        print(f"❌ Error running {script_name}: {e}")

if __name__ == "__main__":
    make_scripts_executable()
    
    SCRIPTS = [
        "essential_packages.sh",
        "browser_setup.sh",
        "vscode_setup.sh",
        "whisper_setup.sh",
        "customizations.sh",
        "kali_setup.sh",
        "clamav_setup.sh",
        "harden.sh",
    ]

    for script in SCRIPTS:
        run_bash_script(script)

    print("✅ All scripts executed. Check log for details. Welcome to the Jungle!")
    logging.info("All scripts executed successfully.")
