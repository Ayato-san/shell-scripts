#!/bin/bash
set -e
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

old=$(hostname)

echo "What is the new NAME?"
read new
echo "$new" > /etc/hostname
sed -i -e "s/$old/$new/g" /etc/hosts
echo "The old hostname was $old the new is $new"
echo "The computer will reboot in 3 seconds..."

sleep 3
systemctl reboot
