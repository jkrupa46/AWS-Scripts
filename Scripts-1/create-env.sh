#!/bin/bash

aws ec2 create-security-group --description "This is for ITMO 444 2018" --group-name itmo-444-2018
aws ec2 authorize-security-group-ingress --group-name itmo-444-2018 --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name itmo-444-2018 --protocol tcp --port 80 --cidr 0.0.0.0/0

aws ec2 create-key-pair --key-name 444-sp2 --query 'KeyMaterial' --output text > aws-rsa.pem
chmod 600 aws-rsa.pem ;

aws ec2 run-instances --image-id ami-0552e3455b9bc8d50 --count 1 --instance-type t2.micro --key-name 444-sp2 --security-groups itmo-444-2018
INSTANCE_ID=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].InstanceId")

aws ec2 wait instance-exists --instance-ids $INSTANCE_ID --filters "Name=instance-state-name,Values=running"

IP_ADDRESS=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].PublicIpAddress" | head -1)
ssh ubuntu@$IP_ADDRESS -i ./aws-rsa.pem -vv
