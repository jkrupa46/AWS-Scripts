#!/bin/bash

key=$(aws ec2 describe-instances --query "Reservations[0].Instances[0].KeyName")
security=$(aws ec2 describe-instances --query "Reservations[*].Instances[0].SecurityGroups[*].{Name:GroupName}")

running=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].InstanceId" --filters "Name=instance-state-name,Values=pending,running")

aws ec2 terminate-instances --instance-ids $running

load=$(aws elb describe-load-balancers --query "LoadBalancerDescriptions[].LoadBalancerName")

aws elb delete-load-balancer --load-balancer-name $load

bucket1=$(aws s3api list-buckets --query "Buckets[0].Name")
object1=$(aws s3api list-objects --bucket $bucket1 --query "Contents[0].{Key: Key}")

aws s3api delete-object --bucket $bucket1 --key $object1
aws s3api delete-bucket --bucket $bucket1

aws ec2 wait instance-terminated --instance-ids $running
aws ec2 delete-security-group --group-name $security
aws ec2 delete-key-pair --key-name $key

url=$(aws sqs get-queue-url --queue-name mp2queue)
aws sqs delete-queue --queue-url $url

topic=$(aws sns list-topics --query "Topics[].TopicArn")
aws sns delete-topic --topic-arn $topic

aws rds delete-db-instance --db-instance-identifier itmo-444 --skip-final-snapshot