#Author: Sillypenguin
#Date: 28 Jan 25

# Purpose: main.py for creating custom Linux mint install for open source research and virtual machine use.

import subprocess
import logging

# Configure logging
logging.basicConfig(
    filename="/var/log/vm_python_setup.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)

def run_bash_script(script_name):
    """Runs a given bash script and logs its output."""
    try:
        logging.info(f"Starting script: {script_name}")
        result = subprocess.run(["bash", script_name], capture_output=True, text=True)
        if result.returncode == 0:
            logging.info(f"Script {script_name} completed successfully.")
            logging.info(result.stdout)
        else:
            logging.error(f"Script {script_name} failed with return code {result.returncode}.")
            logging.error(result.stderr)
            raise subprocess.CalledProcessError(result.returncode, script_name)
    except Exception as e:
        logging.error(f"Error while running script {script_name}: {e}")
        raise

if __name__ == "__main__":
    try:
        # Call the script to install essential packages
        run_bash_script("install_essentials.sh")

        # Call the script to install and configure ClamAV
        run_bash_script("setup_clamav.sh")

        logging.info("All scripts executed successfully.")
    except Exception as e:
        logging.error(f"Setup process failed: {e}")
