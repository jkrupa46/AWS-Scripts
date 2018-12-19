#!/bin/bash

sudo apt-get update
sudo apt-get install -y apache2 git

su - ubuntu -l -c 'git clone git@github.com:illinoistech-itm/jkrupa1.git'

cp home/ubuntu/jkrupa1/itmo-444/mp1/index.html /var/www/html

while [ ! -e ./dev/xvdh ]; do echo Waiting for EBS volume to attach; sleep 5; done

sudo mkfs -t ext4 /dev/xvdh
sudo mkdir -p /mnt/datadisk
sudo mount -t ext4 /dev/xvdh /mnt/datadisk/

sudo chown -R ubuntu:ubuntu /mnt/datadisk/

cd var/www/html 
wget https://s3.amazonaws.com/jk-images/IIT-logo.png