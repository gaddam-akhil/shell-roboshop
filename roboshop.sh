#!/bin/bash

SG_ID="sg-0fd4180ae5446c35c"
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z02323877XG4RCKJ3YPJ"
DOMAIN_NAME="gaddam.online"

for INSTANCE in $@
do
InstanceId=$( aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type "t3.micro" \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE}]" \
    --query "Instances[0].InstanceId" \
    --output text )

if [ $INSTANCE == "frontend" ]; then
  IP=$(
     aws ec2 describe-instances \
     --instance-ids $InstanceId \
     --query 'Reservations[*].Instances[*].PublicIpAddress' \
     --output text
 )
 RECORD_NAME="$DOMAIN_NAME"
else
    IP=$(
     aws ec2 describe-instances \
     --instance-ids $InstanceId \
     --query 'Reservations[*].Instances[*].PrivateIpAddress' \
     --output text
    )
    RECORD_NAME="$INSTANCE.$DOMAIN_NAME"
 fi
 echo " IP ADDRESS - $IP"

 aws route53 change-resource-record-sets \
 --hosted-zone-id $ZONE_ID \
 --change-batch '
 {
  "Comment": "Updating record",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "'$RECORD_NAME'",
        "Type": "A",
        "TTL": 1,
        "ResourceRecords": [
          {
            "Value": "'$IP'"
          }
        ]
      }
    }
  ]
}

'
echo "record updated for $INSTANCE"

done
