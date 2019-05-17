@ECHO off
setlocal enabledelayedexpansion
COLOR 03
ECHO.
ECHO #################################
ECHO        CERTIFICATE UPDATER       
ECHO #################################
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
SET /p "choice="
ECHO.
IF "%choice%" == "" SET "validation=http"
IF "%choice%" == "1" SET "validation=http"
IF "%choice%" == "2" SET "validation=cloudflare"
IF NOT "%validation%" == "" goto :winacme

:BadChoiceValidation
Echo %validation%: incorrect input 
ECHO.
Goto :verifymethod

:winacme
ECHO.
ECHO #########################################
ECHO WIN-ACME: Genertating LE SSL Certificates
ECHO #########################################
ECHO.
CD /d "%nginx_loc%"
IF "%validation"=="http" (
  "%nginx_loc%\winacme\wacs.exe" --target manual --host %domain_name%%extras% --validation filesystem --webroot ""%nginx_loc%\www\organizr\html"" --emailaddress "%email%" --accepttos --store pemfiles --pemfilespath ""%nginx_loc%\ssl""
)
IF "%validation%"=="cloudflare" (
  ECHO # Cloudflare email:
  SET /p "cfemail="
  ECHO # Cloudflare API key:
  SET /p "cfapi="
  "%nginx_loc%\winacme\wacs.exe" --target manual --host %domain_name%%extras% --validationmode dns-01 --validation dnsscript --dnsscript "%nginx_loc%\winacme\dns_scripts\cloudflare.ps1" --dnscreatescriptarguments "create '{RecordName}' '{Token}' '!cfemail!' '!cfapi!'" --dnsdeletescriptarguments "remove '{RecordName}' '{Token}' '!cfemail!' '!cfapi!'" --emailaddress "%email%" --accepttos --store pemfiles --pemfilespath ""%nginx_loc%\ssl""
)
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
ECHO ########## Installation Completed ##########