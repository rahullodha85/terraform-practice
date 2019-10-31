#!/bin/bash

sudo apt-get update
sudo apt-get -y install nginx

MYIP=`ifconfig | grep 'addr:10' | awk '{ print $2 }' | cut -d ':' -f2`
echo "this is: $MYIP" >> /var/www/html/index.html
echo "test var: ${TEST}" >> /var/www/html/index.html
