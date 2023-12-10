#!/bin/sh
set -e
cd ~
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
