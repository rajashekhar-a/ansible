#!/bin/bash
UPDATE_DNS_RECORDS() {
  IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$1" | jq ".Reservations[].Instances[].PrivateIpAddress" | grep -v null)
  sed -e "s/DNSNAME/$1-dev.roboshop.internal/" -e "s/IPADDRESS/${IP}/" record.json >/tmp/record.json
  aws route53 change-resource-record-sets --hosted-zone-id Z0954603B8UEBSIZCD99 --change-batch file:///tmp/record.json | jq  &>/dev/null
}

CREATE() {
  COUNT=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$1" | jq ".Reservations[].Instances[].PrivateIpAddress" | grep -v null | wc -l)
  if [ $COUNT -eq 0 ]; then
      aws ec2 run-instances --launch-template "LaunchTemplateId=lt-062ed7701b26d7bd7" --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$1}]" "ResourceType=spot-instances-request,Tags=[{Key=Name,Value=$1}]" | jq &>/dev/null
  else
      echo -e "Instance already exists"
      UPDATE_DNS_RECORDS $1
      return
  fi

  UPDATE_DNS_RECORDS $1
}


