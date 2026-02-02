#!/bin/bash

USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILES="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.gaddam.online

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

dnf install mysql-server -y &>>$LOGS_FILES
VALIDATE $? "Installing mysql"

systemctl enable mysqld &>>$LOGS_FILES
systemctl start mysqld  &>>$LOGS_FILES
VALIDATE $? "ENABLE AND START MYSQL"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOGS_FILES
VALIDATE $? "CHANGING PASWORD"