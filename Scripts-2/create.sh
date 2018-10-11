#!/bin/bash

aws ec2 authorize-security-group-ingress --group-name itmo-444-2018 --protocol tcp --port 4000 --cidr 0.0.0.0/0

aws ec2 run-instances --image-id ami-0552e3455b9bc8d50 --count 1 --instance-type t2.micro --key-name 444-sp2 --security-groups itmo-444-2018 --user-data file://create-env.sh
