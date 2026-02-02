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

dnf module disable redis -y &>>$LOGS_FILES
dnf module enable redis:7 -y &>>$LOGS_FILES
VALIDATE $? "enable redis" 

dnf install redis -y &>>$LOGS_FILES
VALIDATE $? "installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e  '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "ALLOWING REMOTE CONNNECTIN"

systemctl enable redis 
systemctl start redis &>>$LOGS_FILES
VALIDATE $? "start redis"