#!/bin/bash

START_TIME=$(data +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"


mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE 


#check the user have root privilages or not ? 
check_root()
{
    if [ $USERID -ne 0 ]
    then 
        echo -e "$R ERROR: Please run the user with root access $N" | tee -a $LOG_FILE  
        exit 1 #give other than 0 upto 127 
    else 
        echo "You are running with root access" | tee -a $LOG_FILE 
    fi
}

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

print_time()
{
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME - $START_TIME))
    echo -e "Script executed sucessfully, $Y time taken is: $TOTAL_TIME seconds $N"
}

