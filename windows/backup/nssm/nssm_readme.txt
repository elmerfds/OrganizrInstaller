# In case NSSM (https://nssm.cc) source site is down 
1. Uninstall Organizr using the uninstaller or via the uninstall option on the installer
2. Copy the 'nssm.zip' file from OrganizrInstaller-master\windows\backup\nssm to the o2wi (OrganizrInstaller-master\windows\o2wi) folder
3. Edit o2wi_installer.bat and comment out line 157, from 'cscript dl_config\3_nssmdl.vbs //Nologo' TO 'REM cscript dl_config\3_nssmdl.vbs //Nologo' , save and close the file.
4. Run o2wi_installer.bat as admin.
