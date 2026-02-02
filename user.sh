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
dnf module enable nodejs:20 -y &>>$LOGS_FILES
VALIDATE $? "ENABLE NODEJS"

dnf install nodejs -y &>>$LOGS_FILES
VALIDATE $? "Instal Nodejs"


id roboshop &>>$LOGS_FILES
if [ $? -ne 0 ]; then
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILES
   VALIDATE $? "creating system user"
else 
   echo -e "Roboshop user already exit.....$Y skipping $N" 
fi 

mkdir /app &>>$LOGS_FILES
VALIDATE $? "creating a app dir"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip
VALIDATE $? "Downloding User code"

cd /app &>>$LOGS_FILES
VALIDATE $? "MOVE TO APP DIR"

rm -rf /app/* &>>$LOGS_FILES
VALIDATE $? "removing the existing code"

unzip /tmp/user.zip &>>$LOGS_FILES
VALIDATE $? "UNZIPING THE CODE"

npm install &>>$LOGS_FILES
VALIDATE $? "Installing BULD TOOL"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service &>>$LOGS_FILES
VALIDATE $? "ENABLEING SYTEMCTL SERVICE"

systemctl daemon-reload &>>$LOGS_FILES
VALIDATE $? "RELODING"

systemctl enable user 
systemctl start user &>>$LOGS_FILES
VALIDATE $? "ENABLE AND START"




