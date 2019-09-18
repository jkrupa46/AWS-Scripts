#!/bin/bash

echo "Time to submit an image and your information"

echo "Please enter your username."
read username
username=$(echo $username)

echo "Please enter your email"
read email
email=$(echo $email)

echo "Please enter your phone number"
read phonenumber
phoneumber=$(echo $phonenumber)

echo "Your image has been submitted"

url=$(aws sqs get-queue-url --queue-name mp2queue)

aws sqs send-message --queue-url $url --message-body "Pending image work"

echo "Here is the confirmation of pending work into queue"
aws sqs receive message --queue-url $url