#!/bin/bash

sudo apt-get update
sudo apt-get install -y apache2 git curl php php-simplexml unzip zip libapache2-mod-php php-xml php-mysql

cd /home/ubuntu
sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo php composer-setup.php --quiet

# download and install aws-skp-php library and package
sudo php -d memory_limit=-1 composer.phar require aws/aws-sdk-php

su - ubuntu -l -c 'git clone git@github.com:illinoistech-itm/jkrupa1.git'

sudo cp /home/ubuntu/jkrupa1/itmo-444/mp2/*.php /var/www/html
sudo cp /home/ubuntu/jkrupa1/itmo-444/mp2/index.html /var/www/html

sudo systemctl reload apache2

sudo chmod 777 /var/log/html