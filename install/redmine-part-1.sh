#!/bin/sh
set -e

# Get IP and domain name
IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
DOMAIN_NAME=$(sed 's/.\{1\}$//' <<< $(dig +short -x $IP))

clear

echo "--------------------------------------"
echo "  Setting up Redmine"
echo "--------------------------------------"
echo "  IP:           $IP"
echo "  Domain name:  $DOMAIN_NAME"
echo "--------------------------------------"

if [ "$EUID" -ne 0 ];  then
  echo "Please run as root"
  exit
fi

if test -f "/etc/apt/sources.list"; then
    echo "/etc/apt/sources.list exists."
fi

echo "Retrieving latest package list"
apt-get update

echo "Installing packages..."
apt-get install apt-transport-https ca-certificates dirmngr gnupg2 -y
apt-get install apache2 apache2-dev libapache2-mod-passenger mariadb-server mariadb-client build-essential ruby-dev libxslt1-dev libmariadb-dev libxml2-dev zlib1g-dev imagemagick libmagickwand-dev curl -y
echo "Installation success"

echo ""
echo "Configuring mysql"
echo "WRITE this :\"CREATE DATABASE redmine CHARACTER SET utf8mb4;\""
echo "           :\"GRANT ALL PRIVILEGES ON redmine.* TO 'redmineuser'@'localhost' IDENTIFIED BY 'password';\""
echo "           :\"FLUSH PRIVILEGES;\""
mysql
echo "Configuration Complete"

echo ""
echo "Adding redmine user (LINUX)"
/usr/sbin/useradd -r -m -d /opt/redmine -s /usr/bin/bash redmine
/usr/sbin/usermod -aG www-data redmine

echo "Switching to redmine user account"
echo "run now : bash -c \"$(wget -qLO - https://git.ayato-san.fr/shell-scripts/main/install/redmine-part-2.sh)\""
su - redmine
