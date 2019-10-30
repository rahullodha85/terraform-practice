#!/bin/bash
apt-get update
apt-get -y install nginx
echo "<html><body><h1>Hello Nginx!${TEST}!</h1></body></html>" >> /var/www/html/index.html