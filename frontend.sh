#!/bin/bash

source ./common.sh 



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


