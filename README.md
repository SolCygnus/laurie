# laurie
pedo mellon a minno

This is a custom install for Debian based Linux. It was built and checked utilizing the Linux Mint 22.1 Cinnamon.

Installing and running

Step 1. Download Linux Mint 22.1 Cinamon. Install in preferred hypervisor

Step 2. Update, Snapshot, Install git
    From the terminal run:
    sudo apt update && sudo apt upgrade -y
    sudo apt install git

Turn off the VM and create a snapshot. general guidance would be to call it base and today's date.

Step 3. Clone the repo from the terminal.
Open a terminal and run:
    git clone https://github.com/SolCygnus/laurie

Step 4. Make main.py executable and run
From the terminal run:
    chmod +x the main.py
    main.py

If there are any issues you can check the installation log here:
    /var/log/laurie_repo.log



Note: If using VMWare, under the VM settings for Processors ensure you check virtualize IOMMU and under Display uncheck Accelerate 3D graphics. If using VirtualBox ensure guest additions are installed. 