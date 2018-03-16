@ECHO off
title Oraganizr Windows Uninstaller
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
ECHO     \__\/         \__\/             ~~ Uninstaller v1.0
ECHO.      
pause

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
