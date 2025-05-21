#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-06bb0f34e665a4180"
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z00174153HJ610LT4L6PX"
DOMAIN_NAME="daws84s.cloud"

for instance in ${INSTANCES[@]}
do
    INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t2.micro \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance, Tags= [{Key=Name, Value=$instance}]" \
    --query "Instances[0].InstanceId" \
    --output text)
    if [ $instance != "frontend" ]
    then 
        IP=$(aws ec2 describe-instances  --instance-ids $INSTANCE_ID  --query "Reservations[0].Instances[0].PrivateIpAddress"  --output text) 
    else
        IP=$(aws ec2 describe-instances  --instance-ids $INSTANCE_ID  --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
    fi
    echo "$instance IP address is: $IP"
    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch'
  {
    "Comment": "Creating or updating a record set for cognito endpoint"
    ,"Changes": [{
    "Action"              : "UPSERT"
    ,"ResourceRecordSet"  : {
        "Name"              : "'$instance'.'$DOMAIN_NAME'"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
          "Value"             : "'$IP'"
        }]
      }
    }]
  }'
done