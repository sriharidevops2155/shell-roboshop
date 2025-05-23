#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/payment-logs"
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


dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "installing the python app"

if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "System user roboshop is already created... $Y skipping $N"
fi

mkdir -p /app   
VALIDATE $? "Creating app directory" 

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downloading the payments app"

cd /app 
rm -rf /app/*
unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "unzipping payments"

cd /app 
pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "installing dependencies"

cp payment.service  /etc/systemd/system/payment.service 

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "deamon-reload for payment service"

systemctl enable payment &>>$LOG_FILE
VALIDATE $? "enabling payment service"

systemctl start payment &>>$LOG_FILE
VALIDATE $? "staring payment service"


END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME - $START_TIME))

echo -e "Script execution completed sucessfully, $Y time taken:  $TOTAL_TIME Seconds $N" | tee -a $LOG_FILE