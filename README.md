# Laurie
*"Pedo mellon a minno"*  

This is a custom install for Debian-based Linux. It was built and tested using **Linux Mint 22.1 Cinnamon**.

## 🛠️ Installing and Running

### **Step 1: Download and Install Linux Mint 22.1 Cinnamon**
Download and install **Linux Mint 22.1 Cinnamon** in your preferred hypervisor.

---

### **Step 2: Update, Snapshot, and Install Git**
From the terminal, run:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install git
```


📌 After updating, create a snapshot of your VM. A recommended naming convention is:

    "base-YYYY-MM-DD" (e.g., base-2025-01-29).

Step 3: Clone the Repository

Open a terminal and run:

```bash
git clone https://github.com/SolCygnus/laurie
```

Step 4: Make main.py Executable and Run It

Run the following commands in the terminal:

```bash
chmod +x main.py
sudo python3 main.py
```

📜 Logs and Troubleshooting

If there are any issues, check the installation log:

```bash
~/laurie/laurie_repo.log
```

⚙️ VM Hypervisor Settings

If using VMware:

    Under Processors settings, ensure "Virtualize IOMMU" is enabled.
    Under Display settings, uncheck "Accelerate 3D graphics".

If using VirtualBox:

    Ensure Guest Additions is installed.

Enjoy your custom Linux Mint setup!


---

