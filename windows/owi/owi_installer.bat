@ECHO off
setlocal enabledelayedexpansion
SET owi_v=v2.5.3
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
goto check_Permissions
:check_Permissions
    net session >nul 2>&1
    if NOT %errorLevel% == 0 (
        echo Failure: Current permissions inadequate, please run-as administrator.
	echo.
	echo Press any key to terminate.
	pause >nul
	exit 0
    )
ECHO ## Note for SSL site setup:
ECHO - Certificate Type: Support single or wildcard
ECHO - Other: you can check certificate status and renewals by running this command via cmd,
ECHO   for e.g: c:\nginx\winacme\wacs.exe.exe
ECHO - For more info on WIN-ACME, check out their wiki: https://github.com/PKISharp/win-acme/wiki
ECHO.
ECHO ## Port availability check:
echo.
netstat -o -n -a -b | find "LISTENING" | find ":80 " >nul 2>&1
if %ERRORLEVEL% equ 0 (@echo Port 80 unavailable 	- Required for NGINX HTTP) ELSE (@echo Port 80 available 	- Required for NGINX HTTP)
netstat -o -n -a | find "LISTENING" | find ":443 " >nul 2>&1
if %ERRORLEVEL% equ 0 (@echo "port 443 unavailable 	- Required for NGINX HTTPS") ELSE (@echo Port 443 available 	- Required for NGINX HTTPS)
netstat -o -n -a | find "LISTENING" | find ":9000 " >nul 2>&1
if %ERRORLEVEL% equ 0 (@echo Port 9000 unavailable 	- Required for PHP) ELSE (@echo Port 9000 available 		- Required for PHP)
ECHO.
pause
ECHO.

SET nginx_v=1.16.0
SET php_v=7.3.7
SET nssm_v=2.24-101
SET vcr_v=2017
SET win-acme_v=2.0.8
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
MOVE "%~dp0nginx-*" nginx >nul 2>&1
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

ECHO 6. Removing Firewall Rules
netsh advfirewall firewall delete rule name="Organizr - HTTP"
netsh advfirewall firewall delete rule name="Organizr - HTTPS"
ECHO.Done!
ECHO.

ECHO 7. Removing PHP system variables
SETX /m PHP_FCGI_CHILDREN ""
SETX /m PHP_FCGI_MAX_REQUESTS ""
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /F /V PHP_FCGI_CHILDREN
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /F /V PHP_FCGI_MAX_REQUESTS
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

:extradom
ECHO.
ECHO # Do you have any additional domains/subdomains you want a certificate for? [y/n]
SET /p "extra_dom="
ECHO %extra_dom% | findstr /r /c:"%c:~0,1%" 1>NUL 2>NUL && Goto :extradom%extra_dom% || GOTO :BadChoiceextras
ECHO.

IF /I "%extra_dom%" EQU "y" goto :extradomy
IF /I "%extra_dom%" EQU "Y" goto :extradomy
IF /I "%extra_dom%" EQU "n" goto :verifymethod
IF /I "%extra_dom%" EQU "N" goto :verifymethod

:Badchoiceextras
Echo %extra_dom%: incorrect input
ECHO.
Goto :extradom

:extradomy
ECHO.
ECHO # Enter any additional domains you want comma separated with no spaces
ECHO - Example: www.domain.com,domain1.com
SET /p "extras="
SET "extras=,%extras%"

:verifymethod
ECHO.
ECHO # What validation method would you like to use?
ECHO - Press enter to use default method: HTTP
ECHO   1. HTTP
ECHO   2. Cloudflare DNS
ECHO   3. NameCheap DNS
ECHO   4. GoDaddy DNS
SET /p "choice="
ECHO.
IF "%choice%" == "" SET "validation=http"
IF "%choice%" == "1" SET "validation=http"
IF "%choice%" == "2" SET "validation=cloudflare"
IF "%choice%" == "3" SET "validation=namecheap"
IF "%choice%" == "4" SET "validation=godaddy"
IF NOT "%validation%" == "" goto :ssln

:BadChoiceValidation
Echo %validation%: incorrect input
ECHO.
Goto :verifymethod

:extradomn
:ssln
ECHO.
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
IF EXIST %nginx_loc%\conf\nginx.conf (
  REN %nginx_loc%\conf\nginx.conf nginx.conf.bak
)
MOVE "%~dp0nginx-*" nginx >nul 2>&1
MOVE "%~dp0nginx\html" "%~dp0nginx\www" >nul 2>&1
ROBOCOPY "%~dp0nginx " "%nginx_loc%" /E /MOVE /NFL /NDL /NJH /nc /ns /np

ECHO.
ECHO ####################################
ECHO Moving PHP to destination
ECHO ####################################
ECHO.
ROBOCOPY "%~dp0php " "%nginx_loc%\php" /E /MOVE /NFL /NDL /NJH /nc /ns /np

ECHO.
ECHO ####################################
ECHO Moving NSSM to destination
ECHO ####################################
ECHO.
MOVE "%~dp0nssm-*" nssm >nul 2>&1
ROBOCOPY "%~dp0nssm\win64" "C:\Windows\System32" /E /MOVE /NFL /NDL /NJH /nc /ns /np /R:0 /W:1


IF "%ssl_site%"=="y" (
ECHO.
ECHO ####################################
ECHO Moving WIN-ACME to destination
ECHO ####################################
ECHO.
ROBOCOPY "%~dp0winacme" "%nginx_loc%\winacme" /E /MOVE /NFL /NDL /NJH /nc /ns /np
ROBOCOPY "%~dp0dns_scripts" "%nginx_loc%\winacme\dns_scripts" /E /NFL /NDL /NJH /nc /ns /np
COPY "%~dp0owi_sslupdater.bat" "%nginx_loc%\winacme\owi_sslupdater.bat"
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
NSSM install NGINX "%nginx_loc%\nginx.exe"
NSSM set NGINX ObjectName "%userdomain%\%username%" %pass%
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
NSSM install PHP "%nginx_loc%\php\php-cgi.exe"
NSSM set PHP AppParameters -b 127.0.0.1:9000
NSSM set PHP ObjectName "%userdomain%\%username%" %pass%
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
MOVE "%~dp0Organizr-2-master" organizr >nul 2>&1
DEL /s /q "%~dp0Organizr-2-master.zip"
ROBOCOPY organizr "%nginx_loc%\www\organizr\html" /E /MOVE /NFL /NDL /NJH /nc /ns /np
REM RMDIR /s /q organizr

ECHO.
ECHO ####################################
ECHO Updating Nginx and PHP config
ECHO ####################################
ECHO.

COPY "%~dp0config\nginx.conf" "%nginx_loc%\conf\nginx.conf"
COPY "%~dp0config\ssl.conf" "%nginx_loc%\conf\ssl.conf"
IF NOT EXIST "%nginx_loc%\conf\rp-subdomain.conf" (
  COPY "%~dp0config\rp-subdomain.conf" "%nginx_loc%\conf\rp-subdomain.conf"
)
IF NOT EXIST "%nginx_loc%\conf\rp-subfolder.conf" (
  COPY "%~dp0config\rp-subfolder.conf" "%nginx_loc%\conf\rp-subfolder.conf"
)

mkdir "%nginx_loc%\ssl"
mkdir "%nginx_loc%\www\organizr\db"
CD /d "%~dp0"
COPY "%~dp0config\php.ini" "%nginx_loc%\php\php.ini"
CD /d "%nginx_loc%"
nginx -s reload
CD /d "%~dp0"
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
ECHO  - Removing existing Organizr port rules
netsh advfirewall firewall delete rule name="Organizr - HTTP" >nul 2>&1 && netsh advfirewall firewall delete rule name= "Organizr - HTTPS"  >nul 2>&1
ECHO.
ECHO - Adding rule for port 80
netsh advfirewall firewall add rule name="Organizr - HTTP" dir=in action=allow protocol=TCP localport=80
IF "%ssl_site%"=="y" (
ECHO - Adding rule for port 443
netsh advfirewall firewall add rule name="Organizr - HTTPS" dir=in action=allow protocol=TCP localport=443
)

IF "%ssl_site%"=="y" (
ECHO.
ECHO #########################################
ECHO WIN-ACME: Genertating LE SSL Certificates
ECHO #########################################
ECHO.
CD /d "%nginx_loc%"
IF "%validation%"=="http" (
  "%nginx_loc%\winacme\wacs.exe" --target manual --host %domain_name%%extras% --validation filesystem --webroot ""%nginx_loc%\www\organizr\html"" --emailaddress "%email%" --accepttos --store pemfiles --pemfilespath ""%nginx_loc%\ssl""
)
IF "%validation%"=="cloudflare" (
  ECHO # Cloudflare email:
  SET /p "cfemail="
  ECHO # Cloudflare API key:
  SET /p "cfapi="
  "%nginx_loc%\winacme\wacs.exe" --target manual --host %domain_name%%extras% --validationmode dns-01 --validation dnsscript --dnsscript "%nginx_loc%\winacme\dns_scripts\cloudflare.ps1" --dnscreatescriptarguments "create '{RecordName}' '{Token}' '!cfemail!' '!cfapi!'" --dnsdeletescriptarguments "remove '{RecordName}' '{Token}' '!cfemail!' '!cfapi!'" --emailaddress "%email%" --accepttos --store pemfiles --pemfilespath ""%nginx_loc%\ssl""
)
IF "%validation%"=="namecheap" (
  ECHO # NameCheap username:
  SET /p "ncusername="
  ECHO # NameCheap API key:
  SET /p "ncapi="
  "%nginx_loc%\winacme\wacs.exe" --target manual --host %domain_name%%extras% --validationmode dns-01 --validation dnsscript --dnsscript "%nginx_loc%\winacme\dns_scripts\namecheap.ps1" --dnscreatescriptarguments "create '{RecordName}' '{Token}' '!ncusernamel!' '!ncapi!'" --dnsdeletescriptarguments "remove '{RecordName}' '{Token}' '!ncusernamel!' '!ncapi!'" --emailaddress "%email%" --accepttos --store pemfiles --pemfilespath ""%nginx_loc%\ssl""
)
IF "%validation%"=="godaddy" (
  ECHO # GoDaddy key:
  SET /p "gdkey="
  ECHO # GoDaddy secret:
  SET /p "gdsecret="
  "%nginx_loc%\winacme\wacs.exe" --target manual --host %domain_name%%extras% --validationmode dns-01 --validation dnsscript --dnsscript "%nginx_loc%\winacme\dns_scripts\godaddy.ps1" --dnscreatescriptarguments "create '{RecordName}' '{Token}' '!gdkey!' '!gdsecret!'" --dnsdeletescriptarguments "remove '{RecordName}' '{Token}' '!gdkey!' '!gdsecret!'" --emailaddress "%email%" --accepttos --store pemfiles --pemfilespath ""%nginx_loc%\ssl""
)
PAUSE
IF NOT EXIST %nginx_loc%\ssl\%domain_name%-chain.pem (
  ECHO CERT GENERATION FAILED. LEAVING NON-SSL CONFIG.
  REM Switch to ssl_site to n so the url it gives at the end of the script is correct
  SET ssl_site=n
) ELSE (
  COPY "%~dp0config\nginx-ssl.conf" "%nginx_loc%\conf\nginx.conf"
  powershell -command "(Get-Content "%nginx_loc%\conf\nginx.conf").replace('[domain_name]', '%domain_name%') | Set-Content %nginx_loc%\conf\nginx.conf"
)
ECHO.
CD /d "%nginx_loc%"
nginx -s reload
CD /d "%~dp0"
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
ECHO Opening Organizr First Setup Guide:
START https://docs.organizr.app/books/installation/page/first-time-setup
ECHO.

ECHO ############################
ECHO Cleaning up downloaded Files
ECHO ############################
ECHO.
DEL /s /q "%~dp0nginx.zip" >nul 2>&1
ECHO nginx.zip      DELETED
DEL /s /q "%~dp0php.zip" >nul 2>&1
ECHO php.zip        DELETED
DEL /s /q "%~dp0nssm.zip" >nul 2>&1
ECHO nssm.zip       DELETED
DEL /s /q "%~dp0vc_redist.x64.exe" >nul 2>&1
ECHO vc_redist.exe  DELETED
RMDIR /s /q nssm >nul 2>&1
ECHO nssm directory DELETED
DEL /s /q "%~dp0winacme.zip" >nul 2>&1
ECHO winacme.zip    DELETED
ECHO.
ECHO Done!
ECHO.
SET /p "=Exit: " <nul
pause
