#!/bin/bash -e
#Organizr Ubuntu Installer
#author: elmerfdz
version=v7.5.2-3

#Org Requirements
orgreqname=('Unzip' 'NGINX' 'PHP' 'PHP-ZIP' 'PDO:SQLite' 'PHP cURL' 'PHP simpleXML' 'PHP XMLrpc')
orgreq=('unzip' 'nginx' 'php-fpm' 'php-zip' 'php-sqlite3' 'php-curl' 'php-xml' 'php-xmlrpc')


#Nginx config variables
NGINX_LOC="/etc/nginx"
NGINX_SITES="$NGINX_LOC/sites-available"
NGINX_SITES_ENABLED="$NGINX_LOC/sites-enabled"
NGINX_CONFIG="$NGINX_LOC/config"
NGINX_APPS="$NGINX_LOC/conf.d/apps"
WEB_DIR="/var/www"
SED=$(which sed)
CURRENT_DIR=$(dirname "$0")
tmp="/tmp/Organizr"
dlvar=0
cred_folder="/etc/letsencrypt/.secrets/certbot"
LE_WEB="$WEB_DIR/letsencrypt/.well-known/acme-challenge"
debian_detect=$(cut -d: -f2 < <(lsb_release -i)| xargs)
debian_codename_detect=$(cut -d: -f2 < <(lsb_release -c)| xargs)
dns_plugin=''


#Bloody F##### Debian
debain_special_needs()
	{
		if [ "$debian_detect" == "Debian" ] || [ "$debian_detect" == "Raspbian" ];
		then
			apt install apt-transport-https lsb-release ca-certificates -y
			wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
			echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
		fi
}

ubuntu_special_needs()
	{
		if [ "$debian_codename_detect" == "xenial" ];
		then
			apt-get install software-properties-common -y
			add-apt-repository ppa:ondrej/php -y
			apt-get update			
		fi
}

#Organizr Requirement Module
orgreq_mod() 
	{ 
        echo
		if [ "$debian_detect" == "Debian" ] || [ "$debian_detect" == "Raspbian" ];
		then
			echo -e "\e[1;36m> Deploying Debian special needs care package \e[0m"
			echo
			debain_special_needs
		elif [ "$debian_codename_detect" == "xenial" ]
		then
			echo
			ubuntu_special_needs	
		fi
        echo -e "\e[1;36m> Updating apt repositories...\e[0m"
		echo
		apt-get update	    
        echo
		for ((i=0; i < "${#orgreqname[@]}"; i++)) 
		do
		    echo -e "\e[1;36m> Installing ${orgreqname[$i]}...\e[0m"
		    echo
		    apt-get -y install "${orgreq[$i]}"
		    echo
		done
		echo
    }
#Domain validation 
domainval_mod()
	{	
		echo
		while true
		do
			if [ "$options" == "1" ] || [ "$options" == "2" ] || [ "$options" == "4" ]  
			then
				echo -e "\e[1;36m> Enter a domain or a folder name for your install:\e[0m" 
				echo -e "\e[1;36m> E.g domain.com / organizr.local / $(hostname).local / anything.local] \e[0m" 
			else
				echo -e "\e[1;36m> Enter your domain name e.g. domain.com:\e[0m" 
			fi	
			printf '\e[1;36m- \e[0m'
			read -r dname
			DOMAIN=$dname
	
			# check the domain is roughly valid!
			PATTERN="^([[:alnum:]]([[:alnum:]\-]{0,61}[[:alnum:]])?\.)+[[:alpha:]]{2,10}$"
			if [[ "$DOMAIN" =~ $PATTERN ]]; then
			DOMAIN=$(echo "$DOMAIN" | tr '[:upper:]' '[:lower:]')
			echo -e "\e[1;36m> \e[0mCreating vhost file for:" "$DOMAIN"
			break
			else
			echo "> invalid domain name"
			echo
			fi
		done	
	}
#Nginx vhost creation module
vhostcreate_mod()        
       {
        echo
		#domainval_mod
		# Copy the virtual host template
		CONFIG=$NGINX_SITES/$DOMAIN.conf
		echo -e "\e[1;36m> Nginx vhost template type?:\e[0m"
		echo
		echo -e "\e[1;36m[CF] \e[0mCloudFlare"
		echo -e "\e[1;36m[LE] \e[0mLet's Encrypt/Standard [default & recommended]"
		echo
		printf '\e[1;36m- \e[0m'
		read -r vhost_template
		vhost_template=${vhost_template:-LE}
		
		CFvhostcreate_mod
		LEvhostcreate_mod


		# set up web root
		chmod 755 "$CONFIG"

		# create symlink to enable site
		ln -s "$CONFIG" $NGINX_SITES_ENABLED/"$DOMAIN".conf

		echo -e "\e[1;36m> \e[0mSite Created for $DOMAIN"
		echo
       }
CFvhostcreate_mod()        
       {
		if [ "$vhost_template" == "CF" ] || [ "$vhost_template" == "cf" ]
		then
			if [ "$org_v" == "1" ] || [ "$org_v" == "2" ]
			then
				cp "$CURRENT_DIR"/templates/cf/orgv"${org_v}"_cf.template "$CONFIG"
				mkdir -p $NGINX_CONFIG/"$DOMAIN"
				cp -a "$CURRENT_DIR"/config/cf/. $NGINX_CONFIG/"$DOMAIN"
				mv $NGINX_CONFIG/"$DOMAIN"/domain.com.conf $NGINX_CONFIG/"$DOMAIN"/"$DOMAIN".conf
				mv $NGINX_CONFIG/"$DOMAIN"/domain.com_ssl.conf $NGINX_CONFIG/"$DOMAIN"/"${DOMAIN}"_ssl.conf
				CONFIG_DOMAIN=$NGINX_CONFIG/$DOMAIN/$DOMAIN.conf
				mkdir -p $NGINX_CONFIG/"$DOMAIN"/ssl
				chmod -R 755 $NGINX_CONFIG/"$DOMAIN"/ssl
			fi
		fi
	}

LEvhostcreate_mod()        
       {
		echo
		if [ "$vhost_template" == "LE" ] || [ "$vhost_template" == "le" ]; 
		then
			echo -e "\e[1;36m> Do you want to generate Let's Encrypt SSL certs as well? [y/n].\e[0m"
			printf '\e[1;36m- \e[0m'
			read -r LEcert_create
			LEcert_create=${LEcert_create:-Y}
			if [ "$LEcert_create" == "Y" ] || [ "$LEcert_create" == "y" ];
			then		
				echo -e "\e[1;36m> Please note, since you've selected the Let's Encrypt Option, will start by preparing your system to generte LE SSL certs.\e[0m" 
				echo -e "\e[1;36m> Please make sure, you've configured your domain with the correct DNS records.\e[0m"
				echo -e "\e[1;36m> If you're using CloudFlare (CF) as your DNS, then this is supported by this option.\e[0m"
				echo -e "\e[1;36m> If you haven't preparared your setup to carry out the above, then please terminate this script.\e[0m"
				echo 
				echo -e "\e[1;36m> Or press any key to continue...\e[0m"		 
				read -r
				echo 
				echo -e "\e[1;36m> LE Cert type?:\e[0m"
				echo
				echo -e "\e[1;36m[S] \e[0mSingle Domain Cert [Uses HTTP validation, needs Port 80 opened]"
				echo -e "\e[1;36m[W] \e[0mWildcard [Uses DNS validation]"
				echo
				printf '\e[1;36m- \e[0m'
				read -r LEcert_type
				LEcert_type=${LEcert_type:-W}
			

				if [ "$LEcert_type" == "W" ] || [ "$LEcert_type" == "w" ];
				then
					echo
					echo -e "\e[1;36m> Is your domain on Cloudflare? [y/n] .\e[0m"
					echo  "- Going ahead with the above will automate the DNS / dns-01 challenges for you."
					echo  "- To do that, python3-pip & certbot-dns-cloudflare pip3 package wll be installed"
					printf '\e[1;36m- [y/n]: \e[0m'
					read -r dns_plugin
					dns_plugin=${dns_plugin:-n}
					echo		
				fi
			fi	
		
			mkdir -p $NGINX_APPS 								#Apps folder
			mkdir -p $NGINX_CONFIG/"$DOMAIN"
			cp -a "$CURRENT_DIR"/config/apps/. $NGINX_APPS  		#Apps conf files
			cp -a "$CURRENT_DIR"/config/le/. $NGINX_CONFIG/"$DOMAIN" 	#LE conf file

			if [ "$org_v" == "1" ] && [ "$vhost_template" == "LE" ] || [ "$vhost_template" == "le" ]
			then
				LEcertbot_mod
				if [ "$LEcert_create" == "Y" ] || [ "$LEcert_create" == "y" ]
				then
					cp "$CURRENT_DIR"/templates/le/orgv1_le.template "$CONFIG"
					if [ "$LEcert_type" == "W" ] || [ "$LEcert_type" == "w" ]
					then
						subd='www'
						subd_doma="$DOMAIN" 
						serv_name="$subd.$DOMAIN $DOMAIN"  		
			
					elif [ "$LEcert_type" == "S" ] || [ "$LEcert_type" == "s" ]
					then
						subd_doma="$DOMAIN"
						serv_name="$DOMAIN"   
						#Create LE Certbot renewal cron job
					fi

				else
					cp "$CURRENT_DIR"/templates/le/orgv1_le_no_ssl.template "$CONFIG"
					subd_doma="$DOMAIN"
					serv_name="$DOMAIN"
				fi	
					
			elif [ "$org_v" == "2" ] && [ "$vhost_template" == "LE" ] || [ "$vhost_template" == "le" ]
			then
				LEcertbot_mod
				if [ "$LEcert_create" == "Y" ] || [ "$LEcert_create" == "y" ]
				then
					cp "$CURRENT_DIR"/templates/le/orgv2_le.template "$CONFIG"				
					if [ "$LEcert_type" == "W" ] || [ "$LEcert_type" == "w" ]
					then
						subd='www'
						subd_doma="$DOMAIN" 
						serv_name="$subd.$DOMAIN $DOMAIN"  				
							
					elif [ "$LEcert_type" == "S" ] || [ "$LEcert_type" == "s" ]
					then
						subd_doma="$DOMAIN"
						serv_name="$DOMAIN" 
					fi

				else
					cp "$CURRENT_DIR"/templates/le/orgv2_le_no_ssl.template "$CONFIG"
					subd_doma="$DOMAIN"
					serv_name="$DOMAIN"
				fi		
			fi
		fi	
		}

LEcertbot_mod() 
		{
			if [ ! -d "$LE_WEB" ]; then
			mkdir -p $LE_WEB
			fi
			
			#Configuring permissions on LE web folder
			chmod -R 775 $LE_WEB
			chown -R www-data:"$SUDO_USER" $LE_WEB

			#Copy LE TEMP conf file so that LE can connect to server and continue to generate the certs
			cp "$CURRENT_DIR"/templates/le/le_temp.template "$CONFIG"
			$SED -i "s/DOMAIN/$DOMAIN/g" "$CONFIG"
			
			#Delete default.conf nginx site
			mkdir -p $tmp/bk/nginx_default_site
 			if [ -e $NGINX_SITES/default ] 
			then cp -a $NGINX_SITES/default $tmp/bk/nginx_default_site
			fi			
			rm -r -f $NGINX_SITES/default
			rm -r -f $NGINX_SITES_ENABLED/default

			# create symlink to enable site
			ln -s "$CONFIG" $NGINX_SITES_ENABLED/"$DOMAIN".conf

			if [ "$LEcert_create" == "Y" ] || [ "$LEcert_create" == "y" ];
			then 
				# reload Nginx to pull in new config
				/etc/init.d/nginx reload
				if [ "$debian_detect" == "Debian" ] || [ "$debian_detect" == "Raspbian" ];
				then
					if [ "$debian_codename_detect" == "stretch" ];
					then
						echo "deb http://deb.debian.org/debian stretch-backports main" > /etc/apt/sources.list.d/stretch-backport.list
						apt-get update					 
						apt-get install python3-pip -y
						apt-get install certbot python-certbot-nginx -t stretch-backports -y
					elif [ "$debian_codename_detect" == "jessie" ];	
					then
						deb http://ftp.debian.org/debian jessie-backports main
						apt-get update
						wget https://dl.eff.org/certbot-auto -P /opt
						chmod a+x /opt/certbot-auto
					fi	
				else
					##Install certbot packages
					apt-get install software-properties-common
					add-apt-repository universe
					add-apt-repository ppa:certbot/certbot -y
					apt-get update
					apt-get install certbot python-certbot-nginx -y
				fi
			fi

			if [ "$dns_plugin" == "Y" ] || [ "$dns_plugin" == "y" ]
			then
				echo
				echo -e "\e[1;36m> Enter your Cloudflare email.\e[0m"
				printf '\e[1;36m- \e[0m' 
				read -r CF_EMAIL
				echo
				echo -e "\e[1;36m> Enter your Cloudflare API.\e[0m" 
				echo "- You can get your Cloudflare API from here: https://dash.cloudflare.com/profile"
				printf '\e[1;36m- \e[0m' 
				read -r CF_API
				echo

				if [ "$debian_detect" == "Debian" ] || [ "$debian_detect" == "Raspbian" ];
				then
					echo "pip3 already installed"
					pip3 uninstall pyOpenSSL cryptography -y
					pip3 install pyOpenSSL cryptography -U
					sudo pip3 install certbot-dns-cloudflare
					echo
				else
					apt-get install python3-certbot-dns-cloudflare -y
				fi	

				mkdir -p $cred_folder #create secret folder to store Certbot CF plugin creds
				cp -a "$CURRENT_DIR"/config/le-dnsplugins/cf/. $cred_folder #copy CF credentials file
				#Update CF plugin file
				$SED -i "s/CF_EMAIL/$CF_EMAIL/g" $cred_folder/cloudflare.ini
				$SED -i "s/CF_API/$CF_API/g" $cred_folder/cloudflare.ini
				chmod -R 600 $cred_folder #debug

			else
				if [ "$debian_detect" == "Debian" ] || [ "$debian_detect" == "Raspbian" ];
				then
					sudo pip3 install certbot
				else
					apt-get install certbot -y
				fi	
			fi

			if [ "$LEcert_create" == "Y" ] || [ "$LEcert_create" == "y" ];
			then
				## Get wildcard certificate, Let's Encrypt
				echo
				echo -e "\e[1;36m> Enter an email address, which will be used to generate the SSL certs?.\e[0m"
				if [ "$dns_plugin" == "Y" ] || [ "$dns_plugin" == "y" ];
				then
					echo -e "- Press Enter to use \e[1;36m$CF_EMAIL\e[0m or enter a different one"
				fi
				read -r email_var
				email_var=${email_var:-$CF_EMAIL}
			fi	

			if [ "$LEcert_type" == "W" ] || [ "$LEcert_type" == "w" ]
			then
				if [ "$dns_plugin" == "Y" ] || [ "$dns_plugin" == "y" ]
				then
					certbot certonly --dns-cloudflare --dns-cloudflare-credentials $cred_folder/cloudflare.ini --server https://acme-v02.api.letsencrypt.org/directory --email "$email_var" --agree-tos --no-eff-email -d ./*."$DOMAIN" -d "$DOMAIN"
					#Adding wildcard cert auto renewal using CF DNS plugin, untested, let me know if anyone does.
					{ crontab -l 2>/dev/null; echo "20 3 * * * certbot renew --noninteractive --dns-cloudflare --renew-hook "'"/etc/init.d/nginx reload"'""; } | crontab -
				
				else
					certbot certonly --agree-tos --no-eff-email --email "$email_var" --server https://acme-v02.api.letsencrypt.org/directory --manual -d ./*."$DOMAIN" -d "$DOMAIN"
				fi
			
			elif [ "$LEcert_type" == "S" ] || [ "$LEcert_type" == "s" ]
			then
				certbot certonly --webroot --agree-tos --no-eff-email --email "$email_var" -w $WEB_DIR/letsencrypt -d "$DOMAIN" -d "$DOMAIN"
				#Create LE Certbot renewal cron job
				{ crontab -l 2>/dev/null; echo "20 3 * * * certbot renew --noninteractive --renew-hook "'"/etc/init.d/nginx reload"'""; } | crontab -
			fi

			## Once Cert has been generated, delete the created conf file.
			rm -r -f $NGINX_SITES/"$DOMAIN".conf
			rm -r -f $NGINX_SITES_ENABLED/"$DOMAIN".conf
		}

LEcertbot-dryrun_mod() 
		{
			echo
			echo -e "\e[1;36m> Testing Certbot Renew (dry-run).\e[0m"
			certbot renew --dry-run
			echo
		}

LEcertbot-wildcard-renew_mod()
		{
			domainval_mod	
			certbot certonly --manual -d ./*."$DOMAIN" -d "$DOMAIN" --preferred-challenges dns-01 --server https://acme-v02.api.letsencrypt.org/directory
		}

LEcertbot-wc-cf-dns-renew_mod()
		{
			echo
			echo "1. Check renewal status/soft-run"
			echo "2. Force renewal"
			printf '\e[1;36m- \e[0m'
			read -r cfdns_renew
			echo
			if [ "$cfdns_renew" == "1" ]
			then
			certbot renew --dns-cloudflare

			elif [ "$cfdns_renew" == "2" ]
			then
			certbot renew --dns-cloudflare --force-renewal
			fi
		}
		
#Organizr download module
orgdl_mod()
        {
		echo
		echo -e "\e[1;36m> which version of Organizr do you want to install?.\e[0m" 
		echo -e "\e[1;36m[1] \e[0mOrganizr v1 [Out of Support]"
		echo -e "\e[1;36m[2] \e[0mOrganizr v2" 
		echo 
		printf '\e[1;36m> \e[0m'
		read -r org_v
		org_v=${org_v:-2}
		echo
		echo -e "\e[1;36m> which branch do you want to install?\e[0m .eg. 1a or 2a"
		echo
		if [ "$org_v" = "1" ]
		then 
		echo -e "\e[1;36m[1a] \e[0mMaster"
		echo -e "\e[1;36m[1b] \e[0mDev"
		echo -e "\e[1;36m[1c] \e[0mPre-Dev"
		
		elif [ "$org_v" = "2" ]
		then 
		echo -e "\e[1;36m[2a] \e[0mMaster"
		echo -e "\e[1;36m[2b] \e[0mDev"
		fi

		echo
		printf '\e[1;36m> Enter branch code: \e[0m'
		read -r dlvar
		echo
 		if [ -z "$DOMAIN" ]; then
		domainval_mod
		 
		fi		
		echo
		echo -e "\e[1;36m> Where do you want to install Organizr? \e[0m"
		echo -e "\e[1;36m> \e[0m [Press Return for Default = $WEB_DIR/$DOMAIN]"
		echo
		printf '\e[1;36m- \e[0m'
		read -r instvar
		instvar=${instvar:-$WEB_DIR/$DOMAIN}
		echo
		#Org Download and Install
		if [ "$dlvar" = "1a" ]
		then 
		dlbranch=Master

			
		elif [ "$dlvar" = "1b" ]
		then 
		dlbranch=Develop


		elif [ "$dlvar" = "1c" ]
		then 
		dlbranch=Pre-Dev


		elif [ "$dlvar" = "2a" ]
		then
		dlbranch=v2-master


		elif [ "$dlvar" = "2b" ]
		then
		dlbranch=v2-develop

		fi

		echo -e "\e[1;36m> Downloading & Installing Organizr $dlbranch...\e[0m"

		if [ ! -d "$instvar" ]; then
		mkdir -p "$instvar"
		fi
        git clone -b $dlbranch https://github.com/causefx/Organizr.git "$instvar"/html/
                
		if [ ! -d "$instvar/db" ]; then
		mkdir "$instvar"/db
		fi
		#Configuring permissions on web folder
		chmod -R 775 "$instvar"
		chown -R www-data:"$SUDO_USER" "$instvar"
        }
#Nginx vhost config
vhostconfig_mod()
        {      
		#Add in your domain name to your site nginx conf files
		SITE_DIR=$instvar
		$SED -i "s/DOMAIN/$DOMAIN/g" "$CONFIG"
		$SED -i "s!ROOT!$SITE_DIR!g" "$CONFIG"
		$SED -i "s/SERV_NAME/$serv_name/g" "$CONFIG"
		if [ "$vhost_template" == "CF" ] || [ "$vhost_template" == "cf" ]
		then 
			$SED -i "s/DOMAIN/$DOMAIN/g" "$CONFIG_DOMAIN"
			$SED -i "s/SUBD_DOMA/$subd_doma/g" "$CONFIG"
		fi
		if [ "$vhost_template" == "LE" ] || [ "$vhost_template" == "le" ]
		then 
			$SED -i "s/DOMAIN/$DOMAIN/g" $NGINX_CONFIG/"$DOMAIN"/http_server.conf
			$SED -i "s/SUBD_DOMA/$subd_doma/g" $NGINX_CONFIG/"$DOMAIN"/ssl.conf
		fi
		phpv=$(php -v)
		$SED -i "s/VER/$phpv/g" $NGINX_CONFIG/"$DOMAIN"/phpblock.conf

		#Delete default.conf nginx site
		mkdir -p $tmp/bk/nginx_default_site
 		if [ -e $NGINX_SITES/default ] 
		then cp -a $NGINX_SITES/default $tmp/bk/nginx_default_site
		fi			
		rm -r -f $NGINX_SITES/default
		rm -r -f $NGINX_SITES_ENABLED/default
			
		# reload Nginx to pull in new config
		/etc/init.d/nginx reload
        }

#Add site to hosts for local access
addsite_to_hosts_mod()
       {
		echo "127.0.0.1 $DOMAIN" | sudo tee -a /etc/hosts
	   }

uninstall_oui_mod()
        {
			echo
			echo -e "\e[1;36m	PACKAGES	\e[0m"
			echo -e "(Nginx, PHP, PHP Plugins, Certbot & Certbot Cloudflare DNS Plugin)"
			echo
			printf '\e[1;36m- Uninstall Nginx? [y/n]: \e[0m'
			read -r o_uninstaller_nginx
			if [ "$o_uninstaller_nginx" == "Y" ] || [ "$o_uninstaller_nginx" == "y" ]
			then
				echo
				echo -e "\e[1;36m> Uninstalling Nginx\e[0m"
				apt-get purge nginx nginx-common -y
			fi
			echo
			printf '\e[1;36m- Uninstall PHP? [y/n]: \e[0m'
			read -r o_uninstaller_php
			if [ "$o_uninstaller_php" == "Y" ] || [ "$o_uninstaller_php" == "y" ]
			then
				echo
				echo -e "\e[1;36m> Uninstalling PHP\e[0m"
				sudo apt-get purge php*.*-common -y
			fi
			echo
			printf '\e[1;36m- Uninstall Certbot Cloudflare DNS Plugin? [y/n]: \e[0m'
			read -r o_uninstaller_certbot_cf
			if [ "$o_uninstaller_certbot_cf" == "Y" ] || [ "$o_uninstaller_certbot_cf" == "y" ]
			then
				echo
				echo -e "\e[1;36m> Uninstalling Certbot Cloudflare DNS plugin\e[0m"
				if [ "$debian_detect" == "Debian" ] || [ "$debian_detect" == "Raspbian" ]
				then
					sudo pip3 uninstall certbot-dns-cloudflare --yes
				else
					pip3 uninstall certbot-dns-cloudflare --yes
				fi
			fi
			echo
			printf '\e[1;36m- Uninstall Certbot? [y/n]: \e[0m'
			read -r o_uninstaller_certbot
			if [ "$o_uninstaller_certbot" == "Y" ] || [ "$o_uninstaller_certbot" == "y" ]
			then
				echo
				echo -e "\e[1;36m> Uninstalling Certbot\e[0m"
				if [ "$debian_detect" == "Debian" ] || [ "$debian_detect" == "Raspbian" ]
				then
					sudo apt-get remove certbot
					sudo snap remove certbot
					sudo pip3 uninstall certbot --yes
				else
					apt-get remove certbot
					snap remove certbot
					pip3 uninstall certbot --yes
				fi
			fi
			echo
			echo
			echo -e "\e[1;36m>NOTE! You can, if you wish, remove manually:\e[0m"
			echo -e "\e[1;36m - Organizr web folder ($WEB_DIR by default)\e[0m"
			echo -e "\e[1;36m - Unnecessary certbot certificates (/etc/letsencrypt/live/<your-domain> by default)\e[0m"
			echo
			echo -e "\e[1;36mPress any key to continue..\e[0m"
			read -r
			echo
			echo
			echo -e "\e[1;36m> Uninstall complete, Press any key to return to menu...\e[0m"
			read -r
	    }

#Org Install info
orginstinfo_mod()
        {
		#Displaying installation info
		echo
		printf '######################################################'
		echo
		echo -e "     	 \e[1;32mOrganizr $version Install Complete  \e[0m"
		printf '######################################################'
		echo
		echo
		echo -------------------------------------------------------
		echo -e " 	   \e[1;36mAbout your Organizr install    	\e[0m"
		echo -------------------------------------------------------
		echo -e "\e[1;34mInstall directory\e[0m     = $instvar"
		echo -e "\e[1;34mOrganzir files stored\e[0m = $instvar/html "
		echo -e "\e[1;34mOrganzir db directory\e[0m = $instvar/db "
		if [ "$options" != "2" ] 
		then
		echo -e "      \e[1;34mDomain added to\e[0m = /etc/hosts "
		fi
		echo -------------------------------------------------------
		echo
		echo "> Use the above db path when you're setting up the admin user"
		if [ "$options" == "1" ] || [ "$options" == "4" ] 
		then
		echo -e "> Open \e[1;36mhttp(s)://$DOMAIN/\e[0m to create the admin user/setup your DB directory and finalise your Organizr Install"
		echo

		elif [ "$options" == "2" ]
		then
		echo "- Next if you haven't done already, create or configure your Nginx conf to point to the Org installation directoy"
		echo
		fi
        }
#OUI script Updater
oui_updater_mod()
	{
		echo
		echo "Which branch of OUI, do you want to install?"
		echo "- [1] = Master [2] = Dev [3] = Experimental"
		read -r oui_branch_no
		echo

		if [ "$oui_branch_no" = "1" ]
		then 
		oui_branch_name=master
			
		elif [ "$oui_branch_no" = "2" ]
		then 
		oui_branch_name=dev
	
		elif [ "$oui_branch_no" = "3" ]
		then 
		oui_branch_name=experimental
		fi

		git fetch --all
		git reset --hard origin/$oui_branch_name
		git pull origin $oui_branch_name
		echo
        echo -e "\e[1;36mScript updated, reloading now...\e[0m"
		sleep 3s
		chmod +x "${BASH_SOURCE[0]}"
		exec ./ou_installer.sh
	}
#Utilities sub-menu
uti_menus() 
	{
		echo
		echo -e " 	  \e[1;36m|OUI: $version : Utilities|  \e[0m"
		echo
		echo "| 1.| Debian 8.x PHP7 fix	[deprecated]  " 
		echo "| 2.| Let's Encrypt: Test Single Domain Cert Renewal	  " 
		echo "| 3.| Let's Encrypt: Single Domain Cert Renewal 	  " 
		echo "| 4.| Let's Encrypt: Wilcard Cert Renewal	  " 
		echo "| 5.| Let's Encrypt: Wilcard Cert Renewal [Cloudflare DNS Plugin] 					  "
		echo "| 6.| Back 					  "
		echo
		echo
		printf "\e[1;36m> Enter your choice: \e[0m"
	}
#Utilities sub-menu-options
uti_options(){
		read -r uti_options
		case $uti_options in
	 	"1")
			echo "- Your choice 1: Debian 8.x PHP7 fix"
			echo
			apt-get update
			apt install apt-transport-https
			echo "deb http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list
			echo "deb-src http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list
			wget https://www.dotdeb.org/dotdeb.gpg  
			apt-key add dotdeb.gpg
			apt-get update
			echo			
                	echo -e "\e[1;36m> \e[0mPress any key to return to menu..."
			read -r
		;;

			"2")
			echo "- Your choice 2: Let's Encrypt: Test Cert Renewal (non wildcard cert)"
			LEcertbot-dryrun_mod
			echo			
                	echo -e "\e[1;36m> \e[0mPress any key to return to menu..."
			read -r
		;;

			"3")
			echo "- Your choice 3: Let's Encrypt: Force Renewal (non wildcard cert)"
			#Create LE Certbot renewal cron job
			certbot renew --noninteractive --renew-hook "/etc/init.d/nginx reload"
			echo			
                	echo -e "\e[1;36m> \e[0mPress any key to return to menu..."
			read -r
		;;	

			"4")
			echo "- Your choice 4: Let's Encrypt: Wilcard Cert Renewal"
			#LE Wildcard cert renewal
			LEcertbot-wildcard-renew_mod
			echo			
                	echo -e "\e[1;36m> \e[0mPress any key to return to menu..."
			read -r
		;;

			"5")
			echo "- Your choice 5: Let's Encrypt: Wilcard Cert Renewal [Cloudflare DNS Plugin]"
			#LE Wildcard cert renewal
			LEcertbot-wc-cf-dns-renew_mod
			echo			
                	echo -e "\e[1;36m> \e[0mPress any key to return to menu..."
			read -r
		;;							

			"6")
			while true 
			do
			clear
			show_menus
			read_options
			done
		;;

	      	esac
	     }


show_menus() 
	{
		echo
		echo -e " 	  \e[1;36m|ORGANIZR UBUNTU - INSTALLER $version|  \e[0m"
		echo
		echo "| 1.| Organizr + Nginx site Install [Add a site to existing setup]  " 
		echo "| 2.| Organizr Download [Only Org download]		 "
		echo "| 3.| Organizr Requirements Install		  "
		echo "| 4.| Organizr Full Install [Nginx/PHP/Organizr/LE SSL] "
		echo "| 5.| OUI Auto Updater				  "
		echo "| 6.| Utilities				  "
		echo "| 7.| Uninstall 					  "
		echo "| 8.| Quit 					  "
		echo
		echo
		printf "\e[1;36m> Enter your choice: \e[0m"
	}
read_options(){
		read -r options

		case $options in
	 	"1")
			echo "- Your choice: 1. Organizr + Nginx site Install"
			orgdl_mod
			vhostcreate_mod
			vhostconfig_mod
			addsite_to_hosts_mod
			orginstinfo_mod
			unset DOMAIN
            echo -e "\e[1;36m> \e[0mPress any key to return to menu..."
			read -r
			chmod +x "${BASH_SOURCE[0]}"
			exec ./ou_installer.sh			
		;;

	 	"2")
			echo "- Your choice 2: Organizr Web Folder Only Install"
			orgdl_mod
			orginstinfo_mod
			#echo "- Next if you haven't done already, configure your Nginx conf to point to the Org installation directoy"
			echo
			unset DOMAIN
            echo -e "\e[1;36m> \e[0mPress any key to return to menu..."
			read -r
			chmod +x "${BASH_SOURCE[0]}"
			exec ./ou_installer.sh				
		;; 

	 	"3")
			echo "- Your choice 3: Install Organzir Requirements"
			orgreq_mod
            echo -e "\e[1;36m> \e[0mPress any key to return to menu..."
			read -r
			chmod +x "${BASH_SOURCE[0]}"
			exec ./ou_installer.sh				
		;;
        
	 	"4")
			echo "- Your choice 4: Organizr Complete Install (Org + Requirements) "
	        orgreq_mod
			echo -e "\e[1;36m> Press any key to continue with Organizr + Nginx site config\e[0m"
			read -r
			orgdl_mod
	        vhostcreate_mod
			vhostconfig_mod
			addsite_to_hosts_mod
			orginstinfo_mod
			unset DOMAIN
            echo -e "\e[1;36m> \e[0mPress any key to return to menu..."
			read -r
			chmod +x "${BASH_SOURCE[0]}"
			exec ./ou_installer.sh				
		;;

	 	"5")
	        	oui_updater_mod
		;;

		"6")
			while true 
			do
			clear
			uti_menus
			uti_options
			done
		;;

		"7")
			uninstall_oui_mod
			chmod +x "${BASH_SOURCE[0]}"
			exec ./ou_installer.sh					
		;;

		"8")
			exit 0
		;;


	      	esac
	     }

while true 
do
	clear
	show_menus
	read_options
done