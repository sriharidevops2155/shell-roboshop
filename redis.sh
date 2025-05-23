#!/bin/bash

echo ""

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/redis-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"


mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE 


#check the user have root privilages or not ? 
if [ $USERID -ne 0 ]
then 
    echo -e "$R ERROR: Please run the user with root access $N" | tee -a $LOG_FILE  
    exit 1 #give other than 0 upto 127 
else 
    echo "You are running with root access" | tee -a $LOG_FILE 
fi

#validating if installation is sucedded or not 
VALIDATE()
{
    if [ $1 -eq 0 ]
    then
       echo -e "$2 is ...$G SUCESS $N" | tee -a $LOG_FILE 
    else
       echo -e " $2 is ...$R FAILURE $N "| tee -a $LOG_FILE 
        exit 1
    fi
}


dnf module disable redis -y
VALIDATE $? "Disabling redis"

dnf module enable redis:7 -y
VALIDATE $? "Enabling redis:7"

dnf install redis -y
VALIDATE $? "Installing redis:7"

sed -i "s/127.0.0.1/0.0.0.0/" /etc/redis/redis.conf
VALIDATE $? "Updated IP address in redis.conf"



systemctl enable redis 
VALIDATE $? "Enabling redis:7"
systemctl start redis 
VALIDATE $? "Starting redis:7"