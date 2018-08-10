@ECHO off
SET owu_v=v1.5.1
title Oraganizr Windows Uninstaller %owu_v%
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
ECHO     \__\/         \__\/             ~~ %owu_v%
ECHO.      
pause
CD /d %~dp0

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