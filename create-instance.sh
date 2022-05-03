#!/bin/bash

CREATE() {
  COUNT=$( aws ec2 describe-instances --filters "Name=tag:Name,Values=$1" | jq ".Reservations[].Instances[].PrivateIPAddress" | grep -v null | wc -1)

  if [ $COUNT -eq 0 ]; then
    aws ec2 run-instances --image-id ami-0760b951ddb0c20c9 --instance-type t2.micro --security-group-ids sg-0f2014ce1036b2e77 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$1}]" | jq &>/dev/null
  else
    echo -e "\e[1;33m$1 Instance already exists\e[0m"
    return
  sleep 5
  fi
  IP=$(aws ec2 describe-instances --filters  "Name=tag:Name,Values=$1" | jq ".Reservations[].Instances[].PrivateIpAddress" | grep -v null | Xargs )    ## xargs is used to remove the double  quotes
  sed -e "s/DNSNAME/$1.roboshop.internal/" -e "s/IPADDRESS/${IP}/" record.json >/tmp/record.json
  aws route53 change-resource-record-sets --hosted-zone-id Z0255309256KJK6OPCR6M --change-batch file:///tmp/record.json | jq  &>/dev/null
  }