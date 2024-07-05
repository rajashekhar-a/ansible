#!/bin/bash
aws ec2 run-instances --launch-template "LaunchTemplateId=lt-062ed7701b26d7bd7" --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$1}]"  "ResourceType=spot-instances-request,Tags=[{Key=Name,Value=$1}]"
IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$1" | jq ".Reservations[].Instances[].PrivateIpAddress")
sed -e "s/DNSNAME/$1roboshop.internal/" "s/IPADDRESS/${IP}/" record.json > /tmp/record.json
aws route53 change-resource-record-sets --hosted-zone-id Z0954603B8UEBSIZCD99 --change-batch file:///tmp/record.json