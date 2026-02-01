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

cp mongo.repo  /etc/yum.repos.d/mongo.repo
VALIDATE $? "coping mongo repo"

dnf install mongodb-org -y &>>$LOGS_FILES
VALIDATE $? "installing mongodb server"

systemctl enable mongod &>>$LOGS_FILES
VALIDATE $? "enable mongodb" 

systemctl start mongod
VALIDATE $? "start mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "allowing remote connection"

systemctl restart mongod &>>$LOGS_FILES
VALIDATE $? "restart mongodb"