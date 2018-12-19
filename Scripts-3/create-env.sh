#!/bin/bash

echo "Image id is chosen"

imageid=$(echo "ami-0dafbb1ad8e812b12")

echo "Please enter an availability zone. Ex: us-east-2b"
read zone
zone=$(echo $zone)

echo "Please enter a rsa key name"
read keyname
keyname=$(echo $keyname)

echo "Please enter a security group name"
read securitygroup
securitygroup=$(echo $securitygroup)

echo "Please enter the amount of machines to run"
read count
count=$(echo $count)

echo "Please enter an elastic load balancer name"
read elbname
elbname=$(echo $elbname)

echo "S3 storage will be named jk-images"
s3bucketname=$(echo "jk-images")

aws s3api create-bucket --bucket $s3bucketname --region us-east-1
aws s3api wait bucket-exists --bucket $s3bucketname
aws s3api put-bucket-acl --bucket $s3bucketname --acl public-read

wget https://professoralgo.com/wp-content/uploads/2015/08/IIT-logo.png
aws s3api put-object --bucket $s3bucketname --key IIT-logo.png --body IIT-logo.png
aws s3api wait object-exists --bucket $s3bucketname --key IIT-logo.png
aws s3api put-object-acl --bucket $s3bucketname --key IIT-logo.png --acl public-read

aws ec2 create-security-group --description "This is for ITMO 444 2018" --group-name $securitygroup
aws ec2 authorize-security-group-ingress --group-name $securitygroup --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name $securitygroup --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 create-key-pair --key-name $keyname --query 'KeyMaterial' --output text > aws-rsa.pem
chmod 600 aws-rsa.pem

aws ec2 run-instances --image-id $imageid --count $count --instance-type t2.micro --key-name $keyname --security-groups $securitygroup --placement AvailabilityZone=$zone --user-data file://create-app.sh
running=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].InstanceId" --filters "Name=instance-state-name,Values=pending,running")
aws ec2 wait instance-running --instance-ids $running

aws elb create-load-balancer --load-balancer-name $elbname --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80" --availability-zones $zone
aws elb register-instances-with-load-balancer --load-balancer-name $elbname --instances $running
aws elb create-lb-cookie-stickiness-policy --load-balancer-name $elbname --policy-name cookie-policy --cookie-expiration-period 60

aws ec2 create-volume --availability-zone $zone --size 10
aws ec2 create-volume --availability-zone $zone --size 10
aws ec2 create-volume --availability-zone $zone --size 10

ebs1=$(aws ec2 describe-volumes --query "Volumes[0].{ID:VolumeId}" --filters "Name=status,Values=creating,available")
ebs2=$(aws ec2 describe-volumes --query "Volumes[1].{ID:VolumeId}" --filters "Name=status,Values=creating,available")
ebs3=$(aws ec2 describe-volumes --query "Volumes[2].{ID:VolumeId}" --filters "Name=status,Values=creating,available")
aws ec2 wait volume-available --volume-ids $ebs1 $eb2 $eb3

inst1=$(aws ec2 describe-instances --query "Reservations[0].Instances[0].InstanceId" --filters "Name=instance-state-name,Values=pending,running")
inst2=$(aws ec2 describe-instances --query "Reservations[0].Instances[1].InstanceId" --filters "Name=instance-state-name,Values=pending,running")
inst3=$(aws ec2 describe-instances --query "Reservations[0].Instances[2].InstanceId" --filters "Name=instance-state-name,Values=pending,running")

aws ec2 attach-volume --device /dev/xvdh --volume-id $ebs1 --instance-id $inst1
aws ec2 attach-volume --device /dev/xvdh --volume-id $ebs2 --instance-id $inst2
aws ec2 attach-volume --device /dev/xvdh --volume-id $ebs3 --instance-id $inst3



