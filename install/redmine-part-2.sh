#!/bin/sh
set -e
cd ~
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
sed -i -e 's/username: root/username: redmineuser/' /opt/redmine/config/database.yml
sed -i -e 's/password: ""/password: "password"/' /opt/redmine/config/database.yml
sed -i -e 's/transaction_isolation: "READ-COMMITTED"/tx_isolation: "READ-COMMITTED"/' /opt/redmine/config/database.yml
echo "Update complete"
echo "run now : bash -c \"$(wget -qLO - https://git.ayato-san.fr/shell-scripts/main/install/redmine-part-3.sh)\""
exit
