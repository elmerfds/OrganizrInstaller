#!/bin/bash -e
#Setup an Organizr web directory in seconds
echo ---------------------------
echo - "Organizr Installer v1.0"   -
echo ---------------------------
echo

x=Master
y=Dev
z=Pre-Dev

echo "which version of Organizr do you want me to download?"
echo "- Master = [1] Dev = [2] Pre-Dev = [3]"
printf 'Enter a number: '
read -r dlvar
echo
echo "Where do you want to install Organizr?"
printf 'Please enter the full path: '
read instvar
echo

#Org Master Download and Install
if [ $dlvar = "1" ]
then 
echo Downloading the latest Organizr "$x" ...
rm -r -f /tmp/Organizr/master.zip
rm -r -f /tmp/Organizr/Organizr-master
wget --quiet -P /tmp/Organizr/ https://github.com/causefx/Organizr/archive/master.zip
unzip -q /tmp/Organizr/master.zip -d /tmp/Organizr
q=$x
echo Organizr $q downloaded and unzipped
echo
echo Instaling Organizr...
if [ ! -d "$instvar" ]; then
mkdir -p $instvar
fi
cp -a /tmp/Organizr/Organizr-master/. $instvar/html

#Org Dev Download and Install
elif [ $dlvar = "2" ]
then 
echo Downloading the latest Organizr "$y" ...
rm -r -f /tmp/Organizr/develop.zip
rm -r -f /tmp/Organizr/Organizr-develop
wget --quiet -P /tmp/Organizr/ https://github.com/causefx/Organizr/archive/develop.zip
unzip -q /tmp/Organizr/develop.zip -d /tmp/Organizr
q=$y
echo Organizr $q downloaded and unzipped
echo
echo Instaling Organizr...
if [ ! -d "$instvar" ]; then
mkdir -p $instvar
fi
cp -a /tmp/Organizr/Organizr-develop/. $instvar/html

#Org Pre-Dev Download and Install
elif [ $dlvar = "3" ]
then 
echo Downloading the latest Organizr "$z" ...
rm -r -f /tmp/Organizr/cero-dev.zip
rm -r -f /tmp/Organizr/Organizr-cero-dev
wget --quiet -P /tmp/Organizr/ https://github.com/causefx/Organizr/archive/cero-dev.zip
unzip -q /tmp/Organizr/cero-dev.zip -d /tmp/Organizr
q=$z
echo Organizr $q downloaded and unzipped
echo
echo Instaling Organizr...
if [ ! -d "$instvar" ]; then
mkdir -p $instvar
fi
cp -a /tmp/Organizr/Organizr-cero-dev/. $instvar/html
fi

#Moving Org files to destination and configuring permissions
if [ ! -d "$instvar/db" ]; then
mkdir $instvar/db
fi
chmod -R 775 $instvar
chown -R www-data $instvar

#Displaying installation ifo
echo
printf '######################################'
echo
echo "  Organizr $q Installion Complete  "
printf '######################################'
echo
echo
echo ---------------------------------------------
echo "    	About your org install    		"
echo ---------------------------------------------
echo "Installtion directory = $instvar"
echo "Organzir files stored = $instvar/html"
echo "Organzir db directory = $instvar/db "
echo ---------------------------------------------
echo
echo "Next if you haven't done already, configure your Nginx conf to point to the Org installation directoy"
echo "Use the above db path when you're setting up the admin user"
echo "Then visit localhost/index.php or domain.com/index.php to create the admin user and setup your db directory"
echo




