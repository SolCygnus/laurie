# Author: SillyPenguin
# Date: 29 Jan 25
# Purpose: Main.py to install necessary packages (bash scripts). custom build Linux Mint for open source research 

import subprocess
import logging
import os

# Configure logging to ensure all output is stored in one file
LOG_FILE = "/var/log/laurie_repo.log"

logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)

def run_bash_script(script_name):
    """Runs a given bash script and consolidates its output into the main log."""
    script_path = os.path.join(os.path.dirname(__file__), script_name)

    if not os.path.exists(script_path):
        logging.error(f"Script not found: {script_name}")
        print(f"Error: {script_name} not found.")
        return

    try:
        os.chmod(script_path, 0o755)  # Ensure the script has execute permissions
        logging.info(f"Starting script: {script_name}")
        print(f"Executing: {script_name}...")

        with open(LOG_FILE, "a") as log_file:
            result = subprocess.run(["bash", script_path], stdout=log_file, stderr=log_file, text=True)

        if result.returncode == 0:
            logging.info(f"✅ Script {script_name} executed successfully.")
            print(f"✔ {script_name} executed successfully.")
        else:
            logging.error(f"❌ Script {script_name} failed with return code {result.returncode}.")
            print(f"❌ {script_name} failed. Check logs.")
    except Exception as e:
        logging.error(f"❌ Error running {script_name}: {e}")
        print(f"❌ Error running {script_name}: {e}")

if __name__ == "__main__":
    SCRIPTS = [
        "essential_packages.sh",
        "clamav_install.sh",
        "browser_install.sh",
        "vscode_install.sh",
        "whisper_install.sh"
        "customizations.sh",
        "harden.sh",
    ]

    for script in SCRIPTS:
        run_bash_script(script)

    print("✅ All scripts executed. Check log for details. Welcome to the Jungle!")
    logging.info("All scripts executed successfully.")