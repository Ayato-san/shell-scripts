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

if (whoami != root);  then
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
mysql
CREATE DATABASE redmine CHARACTER SET utf8mb4;
GRANT ALL PRIVILEGES ON redmine.* TO 'redmineuser'@'localhost' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;
EXIT;
echo "Configuration Complete"

echo ""
echo "Adding redmine user (LINUX)"
/usr/sbin/useradd -r -m -d /opt/redmine -s /usr/bin/bash redmine
/usr/sbin/usermod -aG www-data redmine

echo "Switching to redmine user account"
su - redmine

echo ""
echo "Downloading Redmine v5.1.1..."
wget --no-check-certificate https://www.redmine.org/releases/redmine-5.1.1.tar.gz
tar -xvzf redmine-5.1.1.tar.gz -C /opt/redmine/ --strip-components=1
rm /opt/redmine/redmine-5.1.1.tar.gz
echo "Download complete"

echo ""
echo "Copying exemples files..."
cp /opt/redmine/config/configuration.yml{.example,}
cp /opt/redmine/config/database.yml{.example,}
cp /opt/redmine/public/dispatch.fcgi{.example,}
echo "Copy complete"

echo ""
echo "Updating database config..."
sed -i -e 's/username: root/username: redmineuser/' database.yml
sed -i -e 's/password: ""/password: "password"/' database.yml
sed -i -e 's/transaction_isolation: "READ-COMMITTED"/tx_isolation: "READ-COMMITTED"/' database.yml
echo "Update complete"
exit

echo ""
echo "Configuring Ruby..."
cd /opt/redmine
gem install bundler

echo "Switching to redmine user account"
su - redmine
bundle install --without development test --path vendor/bundle
bundle exec rake generate_secret_token
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production REDMINE_LANG=fr bundle exec rake redmine:load_default_data
for i in tmp tmp/pdf public/plugin_assets; do [ -d $i ] || mkdir -p $i; done
chown -R redmine:redmine files log tmp public/plugin_assets
chmod -R 755 /opt/redmine
exit
echo "Ruby Configuration complete"
exit

echo ""
echo "Configuring Apache..."
echo "Writing redmine.conf"
echo "<VirtualHost *:80>" > /etc/apache2/sites-available/redmine.conf
echo "	ServerName localhost" >> /etc/apache2/sites-available/redmine.conf
echo "	RailsEnv production" >> /etc/apache2/sites-available/redmine.conf
echo "	DocumentRoot /opt/redmine/public" >> /etc/apache2/sites-available/redmine.conf
echo "" >> /etc/apache2/sites-available/redmine.conf
echo "	<Directory \"/opt/redmine/public\">" >> /etc/apache2/sites-available/redmine.conf
echo "		Allow from all" >> /etc/apache2/sites-available/redmine.conf
echo "		Require all granted" >> /etc/apache2/sites-available/redmine.conf
echo "	</Directory>" >> /etc/apache2/sites-available/redmine.conf
echo "" >> /etc/apache2/sites-available/redmine.conf
echo "	 ErrorLog \${APACHE_LOG_DIR}/redmine_error.log" >> /etc/apache2/sites-available/redmine.conf
echo "	CustomLog \${APACHE_LOG_DIR}/redmine_access.log combined" >> /etc/apache2/sites-available/redmine.conf
echo "</VirtualHost>" >> /etc/apache2/sites-available/redmine.conf
echo "Apache Configuration Complete"

clear
echo "--------------------------------------"
echo "  Setting up Redmine"
echo "--------------------------------------"
echo "  IP:           $IP"
echo "  Domain name:  $DOMAIN_NAME"
echo "--------------------------------------"
echo "Before launching you can verify :"
echo "  - /opt/redmine/config/database.yml"
echo "  - /etc/apache2/sites-available/redmine.conf"
echo ""
echo "run : a2ensite redmine"
echo "run : systemctl reload apache2"
