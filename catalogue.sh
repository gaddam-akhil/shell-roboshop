#!/bin/bash

USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILES="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD

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

id roboshop &>>$LOGS_FILES
if [ $? -ne 0 ]; then
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILES
   VALIDATE $? "creating system user"
else 
   echo -e "Roboshope user already exit.....$Y skipping $N" 
fi   

mkdir -p /app &>>$LOGS_FILES
VALIDATE $? "creating a app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOGS_FILES
VALIDATE $? "downloading catalogue code"

cd /app &>>$LOGS_FILES
VALIDATE $? "moving to app directory"

rm -rf /app/* &>>$LOGS_FILES
VALIDATE $? "removing the existing code"

unzip /tmp/catalogue.zip &>>$LOGS_FILES
VALIDATE $? "unziping the code"

npm install &>>$LOGS_FILES
VALIDATE $? "installing dependancies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service &>>$LOGS_FILES
VALIDATE $? "created systemctl service"

systemctl daemon-reload
systemctl enable catalogue 
systemctl start catalogue
VALIDATE $? "connecting catalogue"






