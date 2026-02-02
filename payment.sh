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


dnf install python3 gcc python3-devel -y
VALIDATE $? "installing Python-devel"

d roboshop &>>$LOGS_FILES
if [ $? -ne 0 ]; then
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILES
   VALIDATE $? "creating system user"
else 
   echo -e "Roboshope user already exit.....$Y skipping $N" 
fi 

mkdir -p /app &>>$LOGS_FILES
VALIDATE $? "Creating a app dir"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
VALIDATE $? "Downloading payment code"

cd /app &>>$LOGS_FILES
VALIDATE $? "Moving to app dir"

rm -rf /app/* &>>$LOGS_FILES
VALIDATE $? "removing the existing code"

unzip /tmp/payment.zip &>>$LOGS_FILES
VALIDATE $? "Unzipinng the code"

cd /app &>>$LOGS_FILES
VALIDATE $? "Moving to app dir"

pip3 install -r requirements.txt &>>$LOGS_FILES
VALIDATE $? "Installing Build app"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "Starting systemctl service"

systemctl daemon-reload &>>$LOGS_FILES
VALIDATE $? "Reload"

systemctl enable payment &>>$LOGS_FILES
systemctl start payment &>>$LOGS_FILES
VALIDATE $? "ENABLING AND STARTING"

