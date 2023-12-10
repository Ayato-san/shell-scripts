#!/bin/sh
set -e
cd ~
echo ""
echo "Configuring Ruby..."
cd /opt/redmine
gem install bundler

echo "Switching to redmine user account"
echo "run now : bash -c \"$(wget -qLO - https://git.ayato-san.fr/shell-scripts/main/install/redmine-part-4.sh)\""
su - redmine
