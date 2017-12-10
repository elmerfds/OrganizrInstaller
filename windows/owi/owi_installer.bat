@echo off
title Oraganizr Windows Installer
echo	    ___       ___       ___   
echo	   /\  \     /\__\     /\  \  
echo	  /::\  \   /:/\__\   _\:\  \ 
echo	 /:/\:\__\ /:/:/\__\ /\/::\__\
echo	 \:\/:/  / \::/:/  / \::/\/__/
echo	  \::/  /   \::/  /   \:\__\  
echo	   \/__/     \/__/     \/__/  
echo.
echo    v0.5 Beta
echo.
pause
ECHO.
ECHO Where do you want to install Nginx? e.g 'c:\nginx'
set /p nginx_loc=
ECHO.
ECHO 1. Downloading Nginx
powershell -Command "(New-Object Net.WebClient).DownloadFile('http://nginx.org/download/nginx-1.12.2.zip', 'nginx.zip')"
powershell -Command "Invoke-WebRequest http://nginx.org/download/nginx-1.12.2.zip -OutFile nginx.zip"
ECHO.    Done!

ECHO 2. Downloading PHP
powershell -Command "(New-Object Net.WebClient).DownloadFile('http://windows.php.net/downloads/releases/php-7.2.0-nts-Win32-VC15-x64.zip', 'php.zip')"
powershell -Command "Invoke-WebRequest http://windows.php.net/downloads/releases/php-7.2.0-nts-Win32-VC15-x64.zip -OutFile php.zip"
ECHO.    Done!

ECHO 3. Downloading NSSM
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://nssm.cc/ci/nssm-2.24-101-g897c7ad.zip', 'nssm.zip')"
powershell -Command "Invoke-WebRequest https://nssm.cc/ci/nssm-2.24-101-g897c7ad.zip -OutFile nssm.zip"
ECHO.    Done!

ECHO 4. Downloading VCRuntime
powershell -Command "Invoke-WebRequest https://download.microsoft.com/download/6/A/A/6AA4EDFF-645B-48C5-81CC-ED5963AEAD48/vc_redist.x86.exe -OutFile vc_redist.x64.exe"
ECHO.    Done!

ECHO.
ECHO 1. Unziping Nginx
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('nginx.zip', '.'); }"
ECHO.    Done!

ECHO 2. Unziping PHP
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('php.zip', 'php'); }"
ECHO.    Done!

ECHO 3. Unziping NSM
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('nssm.zip', '.'); }"
ECHO.    Done!

ECHO.
ECHO Moving Nginx and PHP to destination
ECHO.
move C:\Temp\owi\nginx-* nginx
move C:\Temp\owi\nginx %nginx_loc%
move C:\Temp\owi\nssm-* nssm
move C:\Temp\owi\php %nginx_loc%\php

ECHO.
ECHO Moving NSSM to destination
ECHO.
move C:\Temp\owi\nssm\win64\nssm.exe C:\Windows\System32


ECHO.
ECHO Download Complete...

ECHO.
ECHO Creating Nginx service
ECHO.
ECHO In order to save and reload Nginx configuration, you need to run the NGINX service as the currently logged in user
ECHO Username: %username%
set /p pass=" Password: " 
nssm install nginx %nginx_loc%\nginx.exe
nssm set nginx ObjectName .\%username% %pass%
nssm start nginx
nssm restart nginx


ECHO.
ECHO Installing Visual C++ Redistributable for Visual Studio 2015 [PHP 7+ requirement]
vc_redist.x64.exe /q
ECHO
ECHO Creating PHP service
nssm install php %nginx_loc%\php\php-cgi.exe
nssm set php AppParameters -b 127.0.0.1:9000
nssm set php ObjectName .\%username% %pass%
nssm start php
nssm restart php

ECHO.
ECHO Downloading Organizr Master
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/causefx/Organizr/archive/master.zip', 'master.zip')"
powershell -Command "Invoke-WebRequest https://github.com/causefx/Organizr/archive/master.zip -OutFile master.zip"
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('master.zip', '.'); }"
move %~dp0Organizr-master organizr
del /s /q %~dp0master.zip
xcopy /e /i /y /s organizr %nginx_loc%\html\organizr
rmdir /s /q organizr

ECHO.
ECHO Updating Nginx and PHP config
copy %~dp0config\nginx.conf %nginx_loc%\conf\nginx.conf
cd %nginx_loc%
nginx -s reload
cd %~dp0

copy %~dp0config\php.ini %nginx_loc%\php\php.ini

cd %nginx_loc%
nginx -s reload
cd %~dp0
nssm restart php
nssm restart nginx
echo.
echo Installation complete
echo.
pause