**SCRIPT: browser_setup.sh**
launching firefox and graceful closing to create local .mozilla folder. This foldre is necessary to replace profiles into. Not sure if there is a better way to handle this 

**SCRIPT: clamav_setup.sh**
    Good to go

**SCRIPT: customizaitions.sh**
Currently only setup for virtualbox. Could remove this function and create own script to allow to expand discrenent between virtualbox or vmware.
creating shared folder link. 
vbosxsf group will not show until reboot.


**SCRIPT: essential_packages.sh**

still having issues installing shodan through the script. process works with the standard apt install on the system. root to sudo_user issue.
having an issue installing obsidian. works through commandline and appears to be pulling from kali-rolling. may need separate function and specify apt-get install -t kali-rolling obsidian -y

**SCRIPT: harden.sh**

Modemmanager not removing. Check necessity. Possible differeny name convention. remove if unnecessary

**SCRIPT: kali_setup.sh**
Good to go

**SCRIPT: vscode.sh**
Good to Go

**SCRIPT: whisper_setup.sh**
Does not work



OVERALL: 
Every function should have an overall echo for starting setup and overall success/fail echo at the end. 
create txt document that has synopsis of installs and things performed to system. Include main.py appending from the log all success/fail entries 