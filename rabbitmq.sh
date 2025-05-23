#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/mysql-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

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

cp rabbitmq.sh /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
VALIDATE $? "Adding rabbitmq repo"

dnf install rabbitmq-server -y
VALIDATE $? "Installing rabbitmq-server"

systemctl enable rabbitmq-server
VALIDATE $? "Enabling rabbitmq-server"

systemctl start rabbitmq-server
VALIDATE $? "Starting  rabbitmq-server"

rabbitmqctl add_user roboshop roboshop123
VALIDATE $? "Starting  rabbitmq-server"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"

END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME - $START_TIME))

echo -e "Script execution completed sucessfully, $Y time taken:  $TOTAL_TIME Seconds $N" | tee -a $LOG_FILE