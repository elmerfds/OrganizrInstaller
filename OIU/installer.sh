#!/bin/bash -e

x=Master
y=Dev
z=Pre-Dev

#Nginx config variables
NGINX_LOC='/etc/nginx'
NGINX_SITES='/etc/nginx/sites-available'
NGINX_SITES_ENABLED='/etc/nginx/sites-enabled'
NGINX_CONFIG='/etc/nginx/config2'
WEB_DIR='/var/www'
SED=`which sed`
CURRENT_DIR=`dirname $0`

show_menus() {
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo " 	ORGANIZR - INSTALLER v1.5 "
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo " 1. Organizr + Nginx site isntall" 
echo " 2. Organizr Web Folder Only Install"
echo " 3. Organizr Requirements Install"
echo " 4. Quit"
echo
printf "Enter your choice: "
}
read_options(){
read -r options

	case $options in
	 "1")
		echo "your choice 1"
		echo
		printf "Enter your domanin name: " 
		read -r dname
		DOMAIN=$dname
		echo

		# check the domain is roughly valid!
		PATTERN="^([[:alnum:]]([[:alnum:]\-]{0,61}[[:alnum:]])?\.)+[[:alpha:]]{2,6}$"
		if [[ "$DOMAIN" =~ $PATTERN ]]; then
		DOMAIN=`echo $DOMAIN | tr '[A-Z]' '[a-z]'`
		echo "Creating hosting for:" $DOMAIN
		else
		echo "invalid domain name"
		exit 1 
		fi

		# Copy the virtual host template
		CONFIG=$NGINX_SITES/$DOMAIN.conf
		cp $CURRENT_DIR/virtual_host.template $CONFIG
		cp -a $CURRENT_DIR/config2/ $NGINX_LOC
		mv $NGINX_LOC/config2/domain.com.conf $NGINX_LOC/config2/$DOMAIN.conf
		mv $NGINX_LOC/config2/domain.com_ssl.conf $NGINX_LOC/config2/${DOMAIN}_ssl.conf
		CONFIG_DOMAIN=$NGINX_CONFIG/$DOMAIN.conf
		mkdir -p $NGINX_CONFIG/ssl/$DOMAIN
		chmod -R 755 $NGINX_CONFIG/ssl/$DOMAIN


		# set up web root
		sudo chmod 600 $CONFIG

		# create symlink to enable site
		sudo ln -s $CONFIG $NGINX_SITES_ENABLED/$DOMAIN.conf


		echo
		echo "Site Created for $DOMAIN"

		echo
		echo "which version of Organizr do you want me to download?"
		echo "- Master = [1] Dev = [2] Pre-Dev = [3]"
		echo
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
			
			#Add in your domain name to your site nginx conf file
			SITE_DIR=`echo $instvar`
			sudo $SED -i "s/DOMAIN/$DOMAIN/g" $CONFIG
			sudo $SED -i "s!ROOT!$SITE_DIR!g" $CONFIG
			sudo $SED -i "s/DOMAIN/$DOMAIN/g" $CONFIG_DOMAIN
			
			# reload Nginx to pull in new config
			sudo /etc/init.d/nginx reload

			#Displaying installation info
			echo
			printf '######################################'
			echo
			echo "  Organizr $q Installion Complete  "
			printf '######################################'
			echo
			echo
			echo ---------------------------------------------
			echo "    	About your Organizr install    		"
			echo ---------------------------------------------
			echo "Installtion directory = $instvar"
			echo "Organzir files stored = $instvar/html"
			echo "Organzir db directory = $instvar/db "
			echo ---------------------------------------------
			echo
#echo "Next if you haven't done already, configure your Nginx conf to point to the Org installation directoy"
			echo "Use the above db path when you're setting up the admin user"
			echo "Then visit localhost/index.php or domain.com/index.php to create the admin user and setup your db directory"
			echo
			echo "Press enter to return to menu"
			read
			;;

	 "2")
		echo "your choice 2"
		echo
		echo "which version of Organizr do you want me to download?"
		echo
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
		echo "    	About your Organizr install    		"
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
		echo "Press enter to return to menu"
		read
		;; 

	 "3")
		echo "your choice 3"
		echo "Install Organzir Requirements"
		echo "Updating apt repositories"
		apt-get update
		echo "Installing Nginx"
		apt-get install nginx
		echo "Installing PHP"
		apt-get install php-fpm
		echo "installing PHP-ZIP"
		apt-get install php-zip

		;;

	 "4")
		exit 0;;

      esac
}

while true 
do
	clear
	show_menus
	read_options
done








