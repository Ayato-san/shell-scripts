#!/bin/sh
set -e
cd ~
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
