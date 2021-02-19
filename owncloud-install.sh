#!/bin/bash

## BASIC INSTALL FOR OWNCLOUD ON DEBIAN 10
##
## SCRIPT CRIADO POR BRUNO KAMMERS RIBEIRO
## v0.1  EM 18/02/2021

clear
IP=$(hostname -I)

echo -ne "\nAPT UPDATE...\n\n"
apt update

echo -ne "\nINSTALL MARIADB...\n\n"
apt install mariadb-server mariadb-client -y
systemctl start mariadb && systemctl enable mariadb

echo -ne "\nCONFIGURE PASSWORD MARIADB...\n\n"
mysql_secure_installation

echo -ne "\nCREATE SCHEMA ON DATABASE...\n\n"
#### ADJUST YOUR PASSWORD FOR BD

mysql -u root -p << EOF
CREATE DATABASE owncloud CHARACTER SET utf8;
GRANT ALL PRIVILEGES ON owncloud.* TO 'root'@'localhost' IDENTIFIED BY 'PASSWORD';
FLUSH PRIVILEGES;
\q
EOF

echo -ne "\nINSTALL APACHE / PHP...\n\n"
apt install -y gnupg redis-server redis-tools apache2 libapache2-mod-php7.3 openssl php-imagick php7.3-common \
php7.3-curl php7.3-gd php7.3-imap php7.3-intl php7.3-json php7.3-ldap php7.3-mbstring php7.3-mysql php7.3-pgsql \
php-smbclient php-ssh2 php7.3-sqlite3 php7.3-xml php7.3-zip php-redis php-apcu apt-transport-https
systemctl start apache2 && systemctl enable apache2

echo -ne "\nSOURCE LIST FOR OWNCLOUD...\n\n"
wget -qO- https://download.owncloud.org/download/repositories/stable/Debian_10/Release.key | apt-key add -
echo 'deb https://download.owncloud.org/download/repositories/stable/Debian_10/ /' > /etc/apt/sources.list.d/owncloud.list

echo -ne "\nINSTALL OWNCLOUD...\n\n"
apt update && apt install -y owncloud-complete-files 

echo -ne "\nCONFIGURE APACHE...\n\n"
cat << EOF > /etc/apache2/sites-available/owncloud.conf
Alias /owncloud "/var/www/owncloud/"

<Directory /var/www/owncloud/>
Options +FollowSymlinks
AllowOverride All

<IfModule mod_dav.c>
Dav off
</IfModule>

SetEnv HOME /var/www/owncloud
SetEnv HTTP_HOME /var/www/owncloud

</Directory>
EOF

chown -R www-data: /var/www/owncloud
a2ensite owncloud
systemctl restart apache2

echo -ne "\n\n  F I N I S H E D !\n"
echo -ne "\n\t\t\t\t http://$IP/owncloud \n\n"
