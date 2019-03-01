# OrganizrInstaller
Automated install script for Organizr (github.com/causefx/Organizr). Only Ubuntu/Debian/CentOS and Windows supported right now! 

## OUI (Organizr Ubuntu Installer)

![menu](https://i.imgur.com/r9lajzW.png)

### How do I run it?
1. `sudo apt-get install git`
2. `sudo git clone https://github.com/elmerfdz/OrganizrInstaller /opt/OrganizrInstaller`
3. `cd /opt/OrganizrInstaller/ubuntu/oui`
4. `sudo bash ou_installer.sh`

**Note:** Please make sure to run as sudo.

### FAQ

### Tested on Ubuntu?
- Yes, 16.04

### Tested on Debian?
- Yes, 9.2.1
- Works on 8.x but run the options '6. Utilities' > '1. Debian 8.x PHP7 fix' before attempting any Organizr install options.

## OWI (Organizr Windows Installer)


![menu](https://i.imgur.com/N6u9X7d.png)

### How do I run it?

1. Clone/Download the repo and extract the zip file to your **Desktop**.
2. Navigate to \OrganizrInstaller\windows\o2wi . 
3. Right-click on 'owi_installer.bat' and click on 'Run as administrator'
4. Installer will ask you for the nginx install location, type in the full path as per the e.g. c:\nginx
5. The installer will ask you to provide the password of the current user during installation, the nginx service requires that you run it under a user account instead of the 'Local System' account, if you don't then you won't be able to save and reload your nginx config.

Note: Move the installer files to desktop and run it from there.

### Requirements
- Latest version of PowerShell, if you're on Windows 7/Win Server 2008 [download](https://social.technet.microsoft.com/wiki/contents/articles/21016.how-to-install-windows-powershell-4-0.aspx)
- Windows 10 recommended but it should work on Windows 7 if you have the latest version of PowerShell

### Tested on?
- Windows 10 Pro
- Windows Server 2012 R2

### OS Architecture
- Currently x64 bit OS only.

### Powered by
- [WNPSI](https://github.com/elmerfdz/WNPSI)

## OCI (Organizr CentOS Installer) BETA

![menu](https://i.imgur.com/7nSnAXl.png)

### How do I run it?
1. `sudo yum install git`
2. `sudo git clone https://github.com/elmerfdz/OrganizrInstaller /opt/OrganizrInstaller`
3. `cd /opt/OrganizrInstaller/centos/oci`
4. `sudo bash oc_installer.sh`

**Note:** Please make sure to run as sudo.

### FAQ

### Tested on version?
- CentOS 7
