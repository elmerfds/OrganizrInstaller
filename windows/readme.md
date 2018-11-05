Note: Run scripts as admin

owi = Organizr v1 installer (fresh install of Nginx + PHP + Org v1 only)

o2wi = Organizr v2 Beta installer (fresh install of Nginx + PHP + Org v2 only)

o2wi-ssl = Organizr v2 Beta installer with SSL [LE certs] (fresh install of Nginx + PHP + Org v2 only)

Scripts will be merged later before v2 release.

## OWI (Organizr Windows Installer) BETA


![menu](https://i.imgur.com/N6u9X7d.png)

### How do I run it?
1. Clone/Download the repo and extract the zip file.
2. Navigate to \OrganizrInstaller\windows\owi OR \OrganizrInstaller\windows\o2wi. 
3. Right-click on 'owi_installer.bat' and click on 'Run as administrator'
4. Installer will ask you for the nginx install location, type in the full path as per the e.g. c:\nginx
5. The installer will ask you to provide the password of the current user during installation, the nginx service requires that you run it under a user account instead of the 'Local System' account, if you don't then you won't be able to save and reload your nginx config.

### Tested on?
- Windows 10 Pro (Fall creators update)
- Windows Server 2012 R2

### OS Architecture
- Currently x64 bit OS only.

### Powered by
- [WNPSI](https://github.com/elmerfdz/WNPSI)