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

echo "S3 pre-storage will be named jk-images1"
s3bucketname1=$(echo "jk-images1")

echo "Please enter your IAM profile name for S3. Ex. s3access-profile"
read iam
iam=$(echo $iam)

aws s3api create-bucket --bucket $s3bucketname1 --region us-east-1
aws s3api wait bucket-exists --bucket $s3bucketname1
aws s3api put-bucket-acl --bucket $s3bucketname1 --acl public-read

aws ec2 create-security-group --description "This is for ITMO 444 2018" --group-name $securitygroup
aws ec2 authorize-security-group-ingress --group-name $securitygroup --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name $securitygroup --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 create-key-pair --key-name $keyname --query 'KeyMaterial' --output text > aws-rsa.pem
chmod 600 aws-rsa.pem

aws ec2 run-instances --image-id $imageid --count $count --iam-instance-profile Name=$iam --instance-type t2.micro --key-name $keyname --security-groups $securitygroup --placement AvailabilityZone=$zone --user-data file://create-app.sh
running=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].InstanceId" --filters "Name=instance-state-name,Values=pending,running")
aws ec2 wait instance-running --instance-ids $running

aws elb create-load-balancer --load-balancer-name $elbname --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80" --availability-zones $zone
aws elb register-instances-with-load-balancer --load-balancer-name $elbname --instances $running
aws elb create-lb-cookie-stickiness-policy --load-balancer-name $elbname --policy-name cookie-policy --cookie-expiration-period 60

aws rds create-db-instance --db-name dataserver --db-instance-identifier itmo-444 --master-username controller --master-user-password ilovebunnies --engine mysql --db-instance-class db.t2.micro --allocated-storage 5 --availability-zone $zone
aws rds wait db-instance-available --db-instance-identifier itmo-444 

aws sqs create-queue --queue-name mp2queue

aws sns create-topic --name mp2topic

