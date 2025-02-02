+ Created for OSR purposes and everyday driving a virtual machine on Virtualbox.


RECOMMENDED TO DO:
Open Firefox and close it
Open Google Chrome and close it. Pay attention to not select sharing of usage statistics.
Open a terminal and run the script browser_config.sh. It is located in laurie/utilities. open a terminal in that location and 
type: ./browser_config.sh
This will update bookmarks for both browsers and profile settings for firefox.

**Ensure your set to Bi-directional sharing with clipboard





KALI Linux OSR tools Installed:
recon-ng
sherlock
metagoofil
spiderfoot
theharvester
shodan
sqlitebrowser

OSR CLI tools Installed:
yt-dlp
exiftool
whisper
vscode (python, hexeditor extensions installed)

**Browsers:**
+ Firefox (native to Mint) - default profile has been updated with some hardening, extensions, and bookmarks. You will need to select
+ Bookmark Toolbar - always show and will find a wonderful beggining set of OSR pages.

+ Brave - base install - no changes

+ Google Chrome - Bookmarks installed - you will need to select settings - Bookmarks - Show Bookmarks bar and will have the same as firefox.

+ Tor - requires first time use to finish downloading necessary files



Hardening:
+ Firewall (UFW) set - You can access from the GUI or from CLI. firewall has been set to deny all and only allow internet traffic.

+ ClamAV - Antivirus installed  - crontab setup for weekly updates/run

+ Removed any unnecessary services for a Virtual Environment
+ root account has been locked and guest account disabled
+ permission changes were made to provide stricter control for user directories


Custom Utilties:
+ hash_checker.py (can be ran globally from CLI using command "hash_checker" --help)


Customizations: 
+ Bash Banner change - if you do not like it - figure out how to change it
+ Apps have been added to Desktop