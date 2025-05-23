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

dnf install maven -y

id roboshop &>>$LOG_FILE

if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "System user roboshop is alread created... $Y skipping $N"
fi

mkdir -p /app   
VALIDATE $? "Creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downloading the shipping app"

cd /app
rm -rf /app/* 
unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "unzipping shipping"

mvn clean package &>>$LOG_FILE
VALIDATE $? "Pacakaging Dependencies"

mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "Moving and renaming the jar file"

cp $PWD/shipping.service /etc/systemd/system/shipping.service &>>$LOG_FILE

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "deamon-reload for shipping service"

systemctl enable shipping &>>$LOG_FILE
VALIDATE $? "enabling shipping service"

systemctl start shipping &>>$LOG_FILE
VALIDATE $? "staring shipping service"

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing my sql"

mysql -h mysql.daws84s.cloud -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
mysql -h mysql.daws84s.cloud -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOG_FILE
mysql -h mysql.daws84s.cloud -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
VALIDATE $? "Loading MySQL data"

systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "restart shipping"

END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME - $START_TIME))

echo -e "Script execution completed sucessfully, $Y time taken:  $TOTAL_TIME Seconds $N" | tee -a $LOG_FILE