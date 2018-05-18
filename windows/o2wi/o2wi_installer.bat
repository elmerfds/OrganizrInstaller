@ECHO off
SET owi_v=v0.9.1 Beta
title Oraganizr v2 Windows Installer %owi_v%
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
ECHO Organizr v2 BETA installer
ECHO.  
pause
ECHO.

SET nginx_v=1.12.2
SET php_v=7.2.4
SET nssm_v=2.24-101
SET vcr_v=2017
CD /d %~dp0

ECHO Where do you want to install Nginx? 
ECHO - Press enter to use default and recommended directory: c:\nginx
SET /p "nginx_loc="
IF "%nginx_loc%" == "" (
  set nginx_loc=c:\nginx
)
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

ECHO.
ECHO 1. Unzipping Nginx
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('nginx.zip', '.'); }"
ECHO.    Done!

ECHO 2. Unzipping PHP
powershell -Command "(Add-Type -AssemblyName System.IO.Compression.Filesystem)"
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('php.zip', 'php'); }"
ECHO.    Done!

ECHO 3. Unzipping NSM
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('nssm.zip', '.'); }"
ECHO.    Done!

ECHO.
ECHO Moving Nginx and PHP to destination
ECHO.
MOVE %~dp0nginx-* nginx
MOVE %~dp0nginx\html %~dp0nginx\www
ROBOCOPY %~dp0nginx %nginx_loc% /E /MOVE /NFL /NDL /NJH /nc /ns /np
MOVE %~dp0nssm-* nssm
ROBOCOPY %~dp0php %nginx_loc%\php /E /MOVE /NFL /NDL /NJH /nc /ns /np

ECHO.
ECHO Moving NSSM to destination
ECHO.
ROBOCOPY %~dp0nssm\win64\ C:\Windows\System32 /E /MOVE /NFL /NDL /NJH /nc /ns /np /R:0 /W:1


ECHO.
ECHO Download Completed...

ECHO.
ECHO Creating Nginx service
ECHO.
ECHO In order to save and reload Nginx configuration, you need to run the NGINX service as the currently logged in user
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
ECHO Creating PHP service
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
ECHO Downloading Organizr Master
ECHO.
cscript dl_config\5_orgdl.vbs //Nologo
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('Organizr-2-develop.zip', '.'); }"
MOVE %~dp0Organizr-2-develop organizr
DEL /s /q %~dp0Organizr-2-develop.zip
ROBOCOPY organizr %nginx_loc%\www\organizr\html /E /MOVE /NFL /NDL /NJH /nc /ns /np
REM RMDIR /s /q organizr

ECHO.
ECHO #############################
ECHO Updating Nginx and PHP config
ECHO #############################
ECHO.
COPY %~dp0config\nginx.conf %nginx_loc%\conf\nginx.conf
mkdir %nginx_loc%\www\organizr\db
CD /d %nginx_loc%
nginx -s reload
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
ECHO ########## Installation Completed ##########
ECHO.
SET /p "=To open Organizr v2 [http://localhost] " <nul
pause
START http://localhost
ECHO.
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
ECHO.
ECHO Done!
ECHO.
SET /p "=Exit: " <nul
pause