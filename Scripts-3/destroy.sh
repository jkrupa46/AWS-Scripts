#!/bin/bash

key=$(aws ec2 describe-instances --query "Reservations[0].Instances[0].KeyName")
security=$(aws ec2 describe-instances --query "Reservations[*].Instances[0].SecurityGroups[*].{Name:GroupName}")

ebs1=$(aws ec2 describe-volumes --query "Volumes[0].{ID:VolumeId}" --filters "Name=size,Values=10")
ebs2=$(aws ec2 describe-volumes --query "Volumes[1].{ID:VolumeId}" --filters "Name=size,Values=10")
ebs3=$(aws ec2 describe-volumes --query "Volumes[2].{ID:VolumeId}" --filters "Name=size,Values=10")

aws ec2 detach-volume --volume-id $ebs1 --force
aws ec2 detach-volume --volume-id $ebs2 --force
aws ec2 detach-volume --volume-id $ebs3 --force

aws ec2 wait volume-available --volume-ids $ebs1 $eb2 $eb3

aws ec2 delete-volume --volume-id $ebs1
aws ec2 delete-volume --volume-id $ebs2
aws ec2 delete-volume --volume-id $ebs3

running=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].InstanceId" --filters "Name=instance-state-name,Values=pending,running")

aws ec2 terminate-instances --instance-ids $running

load=$(aws elb describe-load-balancers --query "LoadBalancerDescriptions[].LoadBalancerName")

aws elb delete-load-balancer --load-balancer-name $load

bucket=$(aws s3api list-buckets --query "Buckets[].Name")
object=$(aws s3api list-objects --bucket $bucket --query "Contents[].{Key: Key}")

aws s3api delete-object --bucket $bucket --key $object
aws s3api delete-bucket --bucket $bucket

aws ec2 wait instance-terminated --instance-ids $running
aws ec2 delete-security-group --group-name $security
aws ec2 delete-key-pair --key-name $key