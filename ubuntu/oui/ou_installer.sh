#!/bin/bash -e
#Organizr Ubuntu Installer
version=v2.0.0

x=Master
y=Dev
z=Pre-Dev


#Nginx config variables
NGINX_LOC='/etc/nginx'
NGINX_SITES='/etc/nginx/sites-available'
NGINX_SITES_ENABLED='/etc/nginx/sites-enabled'
NGINX_CONFIG='/etc/nginx/config'
WEB_DIR='/var/www'
SED=`which sed`
CURRENT_DIR=`dirname $0`
tmp='/tmp/Organizr'

#Modules
#Organizr Requirement Module
orgreq_mod() {     
                echo
                echo -e "\e[1;36mUpdating apt repositories...\e[0m"
		echo
	        apt-get update
                echo
                echo -e "\e[1;36mInstalling Unzip...\e[0m"
		echo
                apt-get -y install unzip
                echo
		echo -e "\e[1;36mInstalling Nginx...\e[0m"
                echo
		apt-get -y install nginx
		echo
		echo -e "\e[1;36mInstalling PHP...\e[0m"
		echo
		apt-get -y install php-fpm
		echo
		echo -e "\e[1;36mInstalling PHP-ZIP...\e[0m"
		echo
		apt-get -y install php-zip
		echo
		echo -e "\e[1;36mInstalling PDO:SQLite...\e[0m"
		echo
		apt-get -y install php-sqlite3
		echo 
		echo -e "\e[1;36mInstalling PHP cURL...\e[0m"
		echo
		apt-get -y install php-curl
		echo
		echo -e "\e[1;36mInstalling PHP simpleXML...\e[0m"
		echo
		apt-get -y install php-xml
		echo
		echo -e "\e[1;36mOrganizr Requirements have been installed successfully...\e[0m"
		echo
                }
#Nginx vhost creation module
vhostcreate_mod()        
       {
        echo
		printf "\e[1;36mEnter your domanin name: \e[0m" 
		read -r dname
		DOMAIN=$dname
		echo

		# check the domain is roughly valid!
		PATTERN="^([[:alnum:]]([[:alnum:]\-]{0,61}[[:alnum:]])?\.)+[[:alpha:]]{2,6}$"
		if [[ "$DOMAIN" =~ $PATTERN ]]; then
		DOMAIN=`echo $DOMAIN | tr '[A-Z]' '[a-z]'`
		echo "- Creating vhost file for:" $DOMAIN
		else
		echo "invalid domain name"
		exit 1 
		fi

		# Copy the virtual host template
		CONFIG=$NGINX_SITES/$DOMAIN.conf
		cp $CURRENT_DIR/virtual_host.template $CONFIG
		cp -a $CURRENT_DIR/config/ $NGINX_LOC
		mv $NGINX_LOC/config/domain.com.conf $NGINX_LOC/config/$DOMAIN.conf
		mv $NGINX_LOC/config/domain.com_ssl.conf $NGINX_LOC/config/${DOMAIN}_ssl.conf
		CONFIG_DOMAIN=$NGINX_CONFIG/$DOMAIN.conf
		mkdir -p $NGINX_CONFIG/ssl/$DOMAIN
		chmod -R 755 $NGINX_CONFIG/ssl/$DOMAIN


		# set up web root
		sudo chmod 600 $CONFIG

		# create symlink to enable site
		sudo ln -s $CONFIG $NGINX_SITES_ENABLED/$DOMAIN.conf

		echo
		echo "- Site Created for $DOMAIN"
		echo
       }
#Organizr download module
orgdl_mod()
        {
		echo	      
		echo -e "\e[1;36mwhich version of Organizr do you want me to download?.\e[0m"
		echo "- Master = [1] Dev = [2] Pre-Dev = [3]"
		echo
		printf '\e[1;36mEnter a number: \e[0m'
		read -r dlvar
		echo
		echo -e "\e[1;36mWhere do you want to install Organizr?.\e[0m"
		printf 'Please enter the full path: '
		read instvar
		echo

			#Org Master Download and Install
			if [ $dlvar = "1" ]
			then 
			echo -e "\e[1;36mDownloading the latest Organizr "$x" ...\e[0m"
			rm -r -f /tmp/Organizr/master.zip
			rm -r -f /tmp/Organizr/Organizr-master
			wget --quiet -P /tmp/Organizr/ https://github.com/causefx/Organizr/archive/master.zip
			unzip -q /tmp/Organizr/master.zip -d /tmp/Organizr
			q=$x
			echo "- Organizr $q downloaded and unzipped"
			echo
			echo -e "\e[1;36mInstalling Organizr...\e[0m"
			if [ ! -d "$instvar" ]; then
			mkdir -p $instvar
			fi
			cp -a /tmp/Organizr/Organizr-master/. $instvar/html

			#Org Dev Download and Install
			elif [ $dlvar = "2" ]
			then 
			echo -e "\e[1;36mDownloading the latest Organizr "$y" ...\e[0m"
			rm -r -f /tmp/Organizr/develop.zip
			rm -r -f /tmp/Organizr/Organizr-develop
			wget --quiet -P /tmp/Organizr/ https://github.com/causefx/Organizr/archive/develop.zip
			unzip -q /tmp/Organizr/develop.zip -d /tmp/Organizr
			q=$y
			echo "- Organizr $q downloaded and unzipped"
			echo
			echo -e "\e[1;36mInstalling Organizr...\e[0m"
			if [ ! -d "$instvar" ]; then
			mkdir -p $instvar
			fi
			cp -a /tmp/Organizr/Organizr-develop/. $instvar/html

			#Org Pre-Dev Download and Install
			elif [ $dlvar = "3" ]
			then 
			echo -e "\e[1;36mDownloading the latest Organizr "$z" ...\e[0m"
			rm -r -f /tmp/Organizr/cero-dev.zip
			rm -r -f /tmp/Organizr/Organizr-cero-dev
			wget --quiet -P /tmp/Organizr/ https://github.com/causefx/Organizr/archive/cero-dev.zip
			unzip -q /tmp/Organizr/cero-dev.zip -d /tmp/Organizr
			q=$z
			echo "- Organizr $q downloaded and unzipped"
			echo           
			echo -e "\e[1;36mInstalling Organizr...\e[0m"
			if [ ! -d "$instvar" ]; then
			mkdir -p $instvar
			fi
			cp -a /tmp/Organizr/Organizr-cero-dev/. $instvar/html
			fi
            if [ ! -d "$instvar/db" ]; then
			mkdir $instvar/db
			fi
			#Configuring permissions on web folder
			chmod -R 775 $instvar
			chown -R www-data $instvar
        }
#Nginx vhost config
vhostconfig_mod()
        {      
			#Add in your domain name to your site nginx conf files
			SITE_DIR=`echo $instvar`
			sudo $SED -i "s/DOMAIN/$DOMAIN/g" $CONFIG
			sudo $SED -i "s!ROOT!$SITE_DIR!g" $CONFIG
			sudo $SED -i "s/DOMAIN/$DOMAIN/g" $CONFIG_DOMAIN

			#Delete default.conf nginx site
			mkdir -p $tmp/bk/nginx_default_site
 			if [ -e $NGINX_SITES/default ] 
			then cp -a $NGINX_SITES/default $tmp/bk/nginx_default_site
			fi			
			rm -r -f $NGINX_SITES/default
			rm -r -f $NGINX_SITES_ENABLED/default
			
			# reload Nginx to pull in new config
			sudo /etc/init.d/nginx reload

        }
#Org Install info
orginstinfo_mod()
        {
			#Displaying installation info
			echo
			printf '############################################'
			echo
			echo -e "     \e[1;32mOrganizr $q Installion Complete  \e[0m"
			printf '############################################'
			echo
			echo
			echo ---------------------------------------------
			echo -e " 	 \e[1;36mAbout your Organizr install    	\e[0m"
			echo ---------------------------------------------
			echo -e "Install directory     = \e[1;35m$instvar \e[0m"
			echo -e "Organzir files stored = \e[1;35m$instvar/html \e[0m"
			echo -e "Organzir db directory = \e[1;35m$instvar/db \e[0m"
			echo ---------------------------------------------
			echo
			echo "- Use the above db path when you're setting up the admin user"
			echo "- Visit localhost/ to create the admin user/setup your db directory and finialise your Organizr Install"
			echo
       }		


show_menus() {
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo -e " 	  \e[1;36mORGANIZR UBUNTU - INSTALLER $version  \e[0m"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo " 1. Organizr + Nginx site Install" 
echo " 2. Organizr Web Folder Only Install"
echo " 3. Organizr Requirements Install"
echo " 4. Organizr Complete Install (Org + Requirements)"
echo " 5. OUI Auto Updater"
echo " 6. Quit"
echo
printf "\e[1;36mEnter your choice: \e[0m"
}
read_options(){
read -r options

	case $options in
	 "1")
		echo "- Your choice: 1. Organizr + Nginx site Install"
		vhostcreate_mod
		orgdl_mod
		vhostconfig_mod
		orginstinfo_mod
		echo "Press any key to return to menu..."
		read
		;;

	 "2")
		echo "- Your choice 2: Organizr Web Folder Only Install"
		orgdl_mod
		orginstinfo_mod
		echo "- Next if you haven't done already, configure your Nginx conf to point to the Org installation directoy"
		echo
		echo "Press any key to return to menu..."
		read
		;; 

	 "3")
		echo "- Your choice 3: Install Organzir Requirements"
		orgreq_mod
        	echo "Press any key to return to menu..."
		read


		;;
        
	 "4")
		echo "- Your choice 4: Organizr Complete Install (Org + Requirements) "
        	orgreq_mod
		echo "- Press any key to continue with Organizr + Nginx site config"
		read
        	vhostcreate_mod
		orgdl_mod
		vhostconfig_mod
		orginstinfo_mod
		echo "Press any key to return to menu..."
		read
		;;
	 "5")
		git reset --hard origin/master
		echo
                echo -e "\e[1;36mScript updated, reloading now...\e[0m"
		sleep 3s
		chmod +x $BASH_SOURCE
		exec ./ou_installer.sh
		;;

	 "6")
		exit 0;;

      esac
}

while true 
do
	clear
	show_menus
	read_options
done









