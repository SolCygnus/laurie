# Laurie
*"Pedo mellon a minno"*  

This is a custom install for Debian-based Linux. It was built and tested using **Linux Mint 22.1 Cinnamon**.

## 🛠️ Installing and Running

### **Step 1: Download and VM Creation**
Download and install **Linux Mint 22.1 Cinnamon** in your preferred hypervisor.

Recommend 8GB Ram and 4 CPU Processors

---
### **Step 2: Limux Mint Install**

Boot up your new VM. Once logged in click the Install Linux Mint CD Rom. Follow the interactive prompts to install the new OS. 
Remember that it is only using the hard disk space that you have allocated.

Once complete, reboot the VM.

### **Step 3: Update, Snapshot, Install Git, Install VirtualBox Guest Additions**
From the terminal, run:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install git
```

Insert Guest Additions from the VirtualBox - Devices toolbar - run. Shutdown system once complete

📌 Create a snapshot. A recommended naming convention is:

    "base-DATE" (e.g., base-29Jan).

### **Step 4: Clone the Repository**

Open a terminal in your home directory and run:

NOTE: when you first open a terminal you are in your home folder. This is where you want/need to execute this script. If you clone the repo 
to another folder or within Documents folder installs will fail.

```bash
git clone https://github.com/SolCygnus/laurie
```

### **Step 5: Make main.py Executable and Run It**

Run the following commands in the terminal:

```bash
chmod +x main.py
sudo python3 main.py
```

### **📜 Logs and Troubleshooting**

If there are any issues, check the installation log:

```bash
~/laurie/laurie_repo.log
```

### **⚙️ VM Hypervisor Settings**

If using VMware:

    Under Processors settings, ensure "Virtualize IOMMU" is enabled.
    Under Display settings, uncheck "Accelerate 3D graphics".

If using VirtualBox:

    Ensure Guest Additions is installed.

Enjoy your custom Linux Mint setup!


---

