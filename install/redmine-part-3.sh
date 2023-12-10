#!/bin/sh
set -e
cd ~
echo ""
echo "Configuring Ruby..."
cd /opt/redmine
gem install bundler

echo "Switching to redmine user account"
su - redmine
