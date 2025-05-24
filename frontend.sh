#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/catalogue-logs"
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

dnf module disable nginx -y  &>>$LOG_FILE
VALIDATE $? "Disabling default niginx module"

dnf module enable nginx:1.24 -y  &>>$LOG_FILE
VALIDATE $? "Enabling niginx:1.24 module"

dnf install nginx -y  &>>$LOG_FILE
VALIDATE $? "Installing niginx:1.24 module"

systemctl enable nginx   &>>$LOG_FILE
VALIDATE $? "Enabling niginx:1.24 module"

systemctl start nginx 
VALIDATE $? "Starting niginx:1.24 module"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Removing default niginx connent"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downloading Frontend"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_FILE  &>>$LOG_FILE
VALIDATE $? "unzipping frontend"

rm -rf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "Remove default nginx conf"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copying niginx.conf"

systemctl restart nginx  &>>$LOG_FILE
VALIDATE $? "Restarting Nginx"


