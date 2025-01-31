**SCRIPT: browser_setup.sh**
launching firefox and graceful closing to create local .mozilla folder. This foldre is necessary to replace profiles into. Not sure if there is a better way to handle this 

**SCRIPT: clamav_setup.sh**
    Good to go

**SCRIPT: customizaitions.sh**
Currently only setup for virtualbox. Could remove this function and create own script to allow to expand discrenent between virtualbox or vmware.
creating shared folder link. Still not adding current user to vboxsf group - causing permissions issues. 
This is recurring issue throughout - root executing scripts performs actions in root account and not sudo user. tried solving with sudo_user variable being called. 

Favorites is not adding to the taskbar for the current user. Maybe trying to do it for the root user is my only guess.

**SCRIPT: essential_packages.sh**

still having issues installing shodan through the script. process works with the standard apt install on the system. root to sudo_user issue.

**SCRIPT: harden.sh**

Modemmanager not removing. Check necessity. Possible differeny name convention. remove if unnecessary

**SCRIPT: kali_setup.sh**

repo added succesfully, need to confirm appropriate package names, used standard names as place holders. recon-ng only one installing at the moment.

**SCRIPT: vscode.sh**
No issues - good to go. Need to confirm Python-debugger is installed on platform once complete

**SCRIPT: whisper_setup.sh**
Does not work

SUDO_USER and logname $(logname)

