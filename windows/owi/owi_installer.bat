@ECHO off
SET owi_v=v1.6.1
title Organizr v2 Windows Installer %owi_v% w/ WIN-ACME support (LE CERTS GEN) 
COLOR 03
ECHO      ___           ___                  
ECHO     /  /\         /  /\           ___   
ECHO    /  /::\       /  /:/_         /__/\  
ECHO   /  /:/\:\     /  /:/ /\        \__\:\ 
ECHO  /  /:/  \:\   /  /:/ /:/_       /  /::\
ECHO /__/:/ \__\:\ /__/:/ /:/ /\   __/  /:/\/
ECHO \  \:\ /  /:/ \  \:\/:/ /:/  /__/\/:/
ECHO  \  \:\  /:/   \  \::/ /:/   \  \::/    
ECHO   \  \:\/:/     \  \:\/:/     \  \:\    
ECHO    \  \::/       \  \::/       \__\/    
ECHO     \__\/         \__\/             ~~ %owi_v%
ECHO.      
ECHO Organizr v2 installer  w/ WIN-ACME support (LE CERTS GEN) 
ECHO.
ECHO ## Note for SSL site setup: 
ECHO - Certificate Type: Single certifcate only! Wildcard certificates aren't supported by WIN-ACME at the moment.
ECHO - Validation: Supports HTTP Validation (http-01) only! so requires port forwarding of ports 80 and 443
ECHO - Other: you can check certificate status and renewals by running this command via cmd, 
ECHO   for e.g: c:\nginx\winacme\letsencrypt.exe
ECHO - For more info on WIN-ACME, check out their wiki: https://github.com/PKISharp/win-acme/wiki
ECHO.   
pause
ECHO.

SET nginx_v=1.15.8
SET php_v=7.3.0
SET nssm_v=2.24-101
SET vcr_v=2017
SET win-acme_v=1.9.12.1
CD /d %~dp0

:purpose
ECHO.
ECHO # Do you want to Install or Uninstall? [i= install, u= uninstall]
SET /p "choice="
ECHO %ssl_site% | findstr /r /c:"%c:~0,1%" >NUL 2>&1 && Goto purpose_"%choice%" || Goto :purpose_badchoice
ECHO.

IF /I "%choice%" EQU "i" goto :purpose_i 
IF /I "%choice%" EQU "I" goto :purpose_i
IF /I "%choice%" EQU "u" goto :purpose_u
IF /I "%choice%" EQU "U" goto :purpose_u

:purpose_badchoice
Echo %choice%: incorrect input 
ECHO.
Goto :purpose

:purpose_u
cls
ECHO.
ECHO Deleting any downloaded tools not cleared from the previous install
DEL /s /q vc_redist.x64.exe >nul 2>&1
DEL /s /q *.zip >nul 2>&1
RMDIR /s /q php >nul 2>&1
RMDIR /s /q nginx >nul 2>&1
MOVE %~dp0nginx-* nginx >nul 2>&1
RMDIR /s /q nginx >nul 2>&1
RMDIR /s /q Organizr-master >nul 2>&1
RMDIR /s /q nssm-2.24-101-g897c7ad >nul 2>&1
RMDIR /s /q nssm >nul 2>&1
ECHO.Done!
ECHO.

ECHO.
ECHO 1. Stopping Nginx service
nssm stop nginx
ECHO.Done!
ECHO.

ECHO 2. Stopping PHP service
nssm stop php
ECHO.
ECHO.Done!

ECHO 3. Removing Nginx service
nssm remove nginx confirm
ECHO.Done!
ECHO.

ECHO 4. Removing PHP service
nssm remove php confirm
ECHO.Done!
ECHO.

ECHO 5. Deleting Nginx folder
RMDIR /s /q c:\nginx >nul 2>&1
ECHO.Done!
ECHO.

rem DEL /s /q c:\Windows\System32\nssm.exe >nul 2>&1
pause
cls
goto :purpose

:purpose_i
ECHO ###################################
ECHO INSTALL LOCATION
ECHO ###################################
ECHO.
ECHO # Where do you want to install Nginx? 
ECHO - Press enter to use default and recommended directory: c:\nginx
SET /p "nginx_loc="
IF "%nginx_loc%" == "" (
  set nginx_loc=c:\nginx
)

ECHO.
ECHO #################################
ECHO SITE TEMPLATE TYPE: HTTP or HTTPS
ECHO #################################
ECHO.

:Cont
ECHO # Do you want to create a SSL enabled site? This option will generate LE SSL certs [y/n] 
SET /p "ssl_site="
ECHO %ssl_site% | findstr /r /c:"%c:~0,1%" 1>NUL 2>NUL && Goto :ssl%ssl_site% || GOTO :BadChoice
ECHO.

IF /I "%ssl_site%" EQU "y" goto :ssly 
IF /I "%ssl_site%" EQU "Y" goto :ssly 
IF /I "%ssl_site%" EQU "n" goto :ssln
IF /I "%ssl_site%" EQU "N" goto :ssln

:Badchoice
Echo %ssl_site%: incorrect input 
ECHO.
Goto :Cont

:ssly 
ECHO.
ECHO # Enter your domain name
SET /p "domain_name=" 
ECHO.
ECHO # Enter an email address for Let's Encrypt renewal and fail notices
SET /p "email=" 
ECHO.

:ssln
ECHO #############################
ECHO Downloading Requirements
ECHO ############################
ECHO.
ECHO 1. Downloading Nginx %nginx_v%
cscript dl_config\1_nginxdl.vbs //Nologo
ECHO.    Done!

ECHO 2. Downloading PHP   %php_v%
cscript dl_config\2_phpdl.vbs //Nologo
ECHO.    Done!

ECHO 3. Downloading NSSM  %nssm_v%
cscript dl_config\3_nssmdl.vbs //Nologo
ECHO.    Done!

ECHO 4. Downloading Visual C++ Redistributable for Visual Studio %vcr_v%
cscript dl_config\4_vcr.vbs //Nologo
ECHO.    Done!

IF "%ssl_site%"=="y" ( 
ECHO 5. Downloading WIN-ACME %win-acme_v%
cscript dl_config\6_winacmedl.vbs //Nologo
ECHO.    Done!
)

ECHO.
ECHO Download Completed...

ECHO.
ECHO #############################
ECHO Unzipping Files
ECHO #############################
ECHO.
ECHO 1. Unziping Nginx
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('nginx.zip', '.'); }"
ECHO.    Done!

ECHO 2. Unziping PHP
powershell -Command "(Add-Type -AssemblyName System.IO.Compression.Filesystem)"
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('php.zip', 'php'); }"
ECHO.    Done!

ECHO 3. Unziping NSM
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('nssm.zip', '.'); }"
ECHO.    Done!

IF "%ssl_site%"=="y" ( 
ECHO 4. Unziping Win-acme
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('winacme.zip', 'winacme'); }"
ECHO.    Done!
)

ECHO.
ECHO ####################################
ECHO Moving Nginx to destination
ECHO ####################################
ECHO.
MOVE %~dp0nginx-* nginx >nul 2>&1
MOVE %~dp0nginx\html %~dp0nginx\www >nul 2>&1
ROBOCOPY %~dp0nginx %nginx_loc% /E /MOVE /NFL /NDL /NJH /nc /ns /np

ECHO.
ECHO ####################################
ECHO Moving PHP to destination
ECHO ####################################
ECHO.
ROBOCOPY %~dp0php %nginx_loc%\php /E /MOVE /NFL /NDL /NJH /nc /ns /np

ECHO.
ECHO ####################################
ECHO Moving NSSM to destination
ECHO ####################################
ECHO.
MOVE %~dp0nssm-* nssm >nul 2>&1
ROBOCOPY %~dp0nssm\win64\ C:\Windows\System32 /E /MOVE /NFL /NDL /NJH /nc /ns /np /R:0 /W:1

IF "%ssl_site%"=="y" ( 
ECHO.
ECHO ####################################
ECHO Moving WIN-ACME to destination
ECHO ####################################
ECHO.
ROBOCOPY %~dp0winacme %nginx_loc%\winacme /E /MOVE /NFL /NDL /NJH /nc /ns /np
)

ECHO.
ECHO ####################################
ECHO Creating Nginx service
ECHO ####################################
ECHO.
ECHO In order to save and reload Nginx configuration, you need to run the NGINX service as the administrator
ECHO.
ECHO Username: %username%
set "psCommand=powershell -Command "$pword = read-host 'Enter Password' -AsSecureString ; ^
    $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); ^
        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
for /f "usebackq delims=" %%p in (`%psCommand%`) do set pass=%%p
ECHO.  
NSSM install NGINX %nginx_loc%\nginx.exe
NSSM set NGINX ObjectName %userdomain%\%username% %pass%
NSSM start NGINX
NSSM restart NGINX


ECHO.
ECHO Installing Visual C++ Redistributable for Visual Studio 2017 [PHP 7+ req]
vc_redist.x64.exe /q /norestart
ECHO.
ECHO ####################################
ECHO Creating PHP service
ECHO ####################################
ECHO.
NSSM install PHP %nginx_loc%\php\php-cgi.exe
NSSM set PHP AppParameters -b 127.0.0.1:9000
NSSM set PHP ObjectName %userdomain%\%username% %pass%
ECHO.
ECHO Setting PHP system variables
SETX /m PHP_FCGI_CHILDREN 3
SETX /m PHP_FCGI_MAX_REQUESTS 128
ECHO.
NSSM start PHP
NSSM restart PHP

ECHO.
ECHO ####################################
ECHO Downloading Organizr v2 
ECHO ####################################
ECHO.
cscript dl_config\5_orgdl.vbs //Nologo
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('Organizr-2-master.zip', '.'); }"
MOVE %~dp0Organizr-2-master organizr >nul 2>&1
DEL /s /q %~dp0Organizr-2-master.zip
ROBOCOPY organizr %nginx_loc%\www\organizr\html /E /MOVE /NFL /NDL /NJH /nc /ns /np
REM RMDIR /s /q organizr

ECHO.
ECHO ####################################
ECHO Updating Nginx and PHP config
ECHO ####################################
ECHO.

COPY %~dp0config\nginx.conf %nginx_loc%\conf\nginx.conf
COPY %~dp0config\ssl.conf %nginx_loc%\conf\ssl.conf

mkdir %nginx_loc%\www\organizr\db
CD /d %~dp0
COPY %~dp0config\php.ini %nginx_loc%\php\php.ini
CD /d %nginx_loc%
nginx -s reload
CD /d %~dp0
NSSM restart PHP
NSSM restart NGINX
ECHO.
timeout /t 4 /nobreak
SET /p "=Nginx status : " <nul
NSSM status NGINX
SET /p "=PHP   status : " <nul
NSSM status PHP
ECHO.

ECHO.
ECHO #########################################
ECHO CREATE WINDOWS FIREWALL RULE
ECHO #########################################
ECHO.
ECHO ADDING RULE FOR PORT 80
netsh advfirewall firewall add rule name="Organizr - HTTP" dir=in action=allow protocol=TCP localport=80
IF "%ssl_site%"=="y" (
ECHO ADDING RULE FOR PORT 443
netsh advfirewall firewall add rule name="Organizr - HTTPS" dir=in action=allow protocol=TCP localport=443
)

IF "%ssl_site%"=="y" ( 
ECHO.
ECHO #########################################
ECHO WIN-ACME: Genertating LE SSL Certificates
ECHO #########################################
ECHO.
CD /d %nginx_loc%
%nginx_loc%\winacme\wacs.exe --target manual --host %domain_name% --validation filesystem --webroot "C:\nginx\www\organizr\html" --emailaddress "%email%" --accepttos
COPY %~dp0config\nginx-ssl.conf %nginx_loc%\conf\nginx.conf
powershell -command "(Get-Content c:\nginx\conf\nginx.conf).replace('[domain_name]', '%domain_name%') | Set-Content c:\nginx\conf\nginx.conf"
ECHO.
CD /d %nginx_loc%
nginx -s reload
CD /d %~dp0
NSSM restart PHP
NSSM restart NGINX
ECHO.
timeout /t 4 /nobreak
SET /p "=Nginx status : " <nul
NSSM status NGINX
SET /p "=PHP   status : " <nul
NSSM status PHP
ECHO.
)

ECHO ########## Installation Completed ##########
IF "%ssl_site%"=="y" ( 
ECHO.
SET /p "=To open Organizr v2 [https://%domain_name%] " <nul
pause
START https://%domain_name%
ECHO.
)
IF "%ssl_site%"=="n" ( 
ECHO.
SET /p "=To open Organizr v2 [http://localhost] " <nul
pause
START http://localhost
ECHO.
)
ECHO ############################
ECHO Cleaning up downloaded Files
ECHO ############################
ECHO.
DEL /s /q %~dp0nginx.zip >nul 2>&1
ECHO nginx.zip      DELETED
DEL /s /q %~dp0php.zip >nul 2>&1
ECHO php.zip        DELETED
DEL /s /q %~dp0nssm.zip >nul 2>&1
ECHO nssm.zip       DELETED
DEL /s /q %~dp0vc_redist.x64.exe >nul 2>&1
ECHO vc_redist.exe  DELETED
RMDIR /s /q nssm >nul 2>&1
ECHO nssm directory DELETED
DEL /s /q %~dp0winacme.zip >nul 2>&1
ECHO winacme.zip        DELETED
ECHO.
ECHO Done!
ECHO.
SET /p "=Exit: " <nul
pause
