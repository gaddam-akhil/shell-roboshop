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

cp rabbitmq.repo  /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "ADDING REPO FILE"

dnf install rabbitmq-server -y &>>$LOGS_FILES
VALIDATE $? "Installing rabbitmq sever"

systemctl enable rabbitmq-server &>>$LOGS_FILES
systemctl start rabbitmq-server &>>$LOGS_FILES
VALIDATE $? "ENABLING AND STARTING SERVER"

rabbitmqctl add_user roboshop roboshop123 &>>$LOGS_FILES
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOGS_FILES
VALIDATE $? "ADDING USER AND SETTING PERMISSION"

