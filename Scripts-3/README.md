## MP1

This is my mp1 project for ITMO-444 Fall 2018. These scripts allow you to automate and destroy ec2 and s3 instances, load balancers, additional storage and etc. 

## Usage Instructions

To run these scripts properly, you need to do several things.

1) First, run the create-env.sh script. However, make sure the create-app.sh script is in the same directory as the create-env.sh script in order for this to work. The create-env.sh allows you to input several variables, so that you can change them to your liking. These variables are availability zone, rsa key name, security group name, number of instances to create, and elastic load balancer name. Any standard naming formats should be good to use for those inputs. Variables like the custom ami id and the s3 object name are already hardcoded. 
2) Once these variables are entered, then the script creates all the instances, storage volumes, s3 buckets, webservers and etc.
3) Once when this script finishes and you are done looking at the instances and etc, then launch the destroy.sh script, which will delete all the instances, volumes, and s3 objects and buckets.