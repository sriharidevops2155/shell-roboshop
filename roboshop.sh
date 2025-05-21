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
        IP=$(aws ec2 describe-instances  --instance-ids $INSTANCE_ID  --query "Reservations[0].Instances[0].PrivateIpAddress")
    else
        IP=$(aws ec2 describe-instances  --instance-ids $INSTANCE_ID  --query "Reservations[0].Instances[0].PublicIpAddress")
    fi
    echo "$instance IP address is: $IP"
done


aws ec2 describe-instances \
    --instance-ids i-0abcdef1234567890 \
    --query "Reservations[0].Instances[0].PrivateIpAddress" \
    --output text



