#!/bin/bash

sudo apt-get update
sudo apt-get -y install nginx

MYIP=$(hostname -I)
echo "this is: $MYIP" >> /var/www/html/index.html
