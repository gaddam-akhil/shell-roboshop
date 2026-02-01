#!/bin/bash

USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILES="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USER_ID -ne 0 ]; then
 echo -e "$R please run this script as root user access $N" | tee -a $LOGS_FILES
 exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE() {
 if [ $1 -ne 0 ]; then
   echo -e "$2 .... $R FAILURE $N" | tee -a $LOGS_FILES
   exit 1
 else 
   echo -e "$2 .. $G SUCCESS $N" | tee -a $LOGS_FILES
 fi

}

dnf module disable nodejs -y &>>$LOGS_FILES
VALIDATE $? "module disabling"

dnf module enable nodejs:20 -y &>>$LOGS_FILES
VALIDATE $? "enable nodejs:20"

dnf install nodejs -y
VALIDATE $? "installing nodejs" &>>$LOGS_FILES

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILES
VALIDATE $? "creating system user"

mkdir /app 
VALIDATE $? "creating a app directory" &>>$LOGS_FILES

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOGS_FILES
VALIDATE $? "downloading catalogue code"


