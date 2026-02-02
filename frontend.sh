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

dnf module list nginx &>>$LOGS_FILES
VALIDATE $? "MODULE LIST NGINX"

dnf module disable nginx -y &>>$LOGS_FILES
dnf module enable nginx:1.24 -y &>>$LOGS_FILES
VALIDATE "ENABLE NGINX MODULE"

dnf install nginx -y
VALIDATE $? "installing nginx"

systemctl enable nginx &>>$LOGS_FILES
systemctl start nginx &>>$LOGS_FILES
VALIDATE $? "ENABLE AND START NGINX"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "removing default file"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "downloading frontend code"

cd /usr/share/nginx/html &>>$LOGS_FILES
VALIDATE $? "Moving html file"

unzip /tmp/frontend.zip &>>$LOGS_FILES
VALIDATE $? "Unzipping frontend file"

rm -rf /etc/nginx/nginx.conf

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "coping our nginx file"

systemctl restart nginx &>>$LOGS_FILES
VALIDATE $? "restarting nginx"


