#!/bin/bash

USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILES="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MYSQL_HOST=mysql.gaddam.online

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

dnf install maven -y
VALIDATE $? "Installing Maven"

id roboshop &>>$LOGS_FILES
if [ $? -ne 0 ]; then
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILES
   VALIDATE $? "creating system user"
else 
   echo -e "Roboshope user already exit.....$Y skipping $N" 
fi 

mkdir -p /app &>>$LOGS_FILES
VALIDATE $? "creating a app directory"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOGS_FILES
VALIDATE $? "downloading shipping code"

cd /app &>>$LOGS_FILES
VALIDATE $? "moving to app directory"

rm -rf /app/* &>>$LOGS_FILES
VALIDATE $? "removing the existing code"

unzip /tmp/shipping.zip &>>$LOGS_FILES
VALIDATE $? "unziping the code"

cd /app 
VALIDATE $? "MOVING TO APP DIR"

mvn clean package &>>$LOGS_FILES
VALIDATE $? "installing dependancies"

mv target/shipping-1.0.jar shipping.jar  &>>$LOGS_FILES
VALIDATE $? "RENAMING"

cp  $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>>$LOGS_FILES
VALIDATE $? "created systemctl service"

systemctl daemon-reload &>>$LOGS_FILES
VALIDATE $? "RELOADING Sysyemctl"

systemctl enable shipping &>>$LOGS_FILES
systemctl start shipping &>>$LOGS_FILES
VALIDATE $? "ENABLING AND STARTING"

dnf install mysql -y &>>$LOGS_FILES
VALIDATE $? "Installing Mysql"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities'

if [ $? -ne 0 ]; then
mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql
mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql 
mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql
VALIDATE $? "LOADING SCHEMAS"
else
echo -e "data is already loaded.... $Y skipping $N"
fi

systemctl enable shipping &>>$LOGS_FILES
systemctl restart shipping &>>$LOGS_FILES
VALIDATE $? "RESTARTING SHIPPING"


