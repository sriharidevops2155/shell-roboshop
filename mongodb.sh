#!/bin/bash

source ./common.sh 
app_name=mongodb

check_root

cp mongo.repo /etc/yum.repos.d/mongodb.repo
VALIDATE $? "Copying MongoDB repo"

dnf install mongodb-org -y  &>>$LOG_FILE
VALIDATE $? "Installing MongoDB server"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "enabling MongoDB"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Starting MongoDB"

sed -i  's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Editing mongod.conf file from 127.0.0.1 to 0.0.0.0 for remote connections"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restaring MongoDB"

print_time
