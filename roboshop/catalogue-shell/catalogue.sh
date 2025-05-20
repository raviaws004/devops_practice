#!/bin/bash

ID=$(id -u)

TIMESTAMP=$(date "+%F-%T")  # %F = YYYY-MM-DD, %T = HH:MM:SS
LOGFILE="/tmp/$0-$TIMESTAMP.log"


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

MONGODB_HOST=172.31.84.7

echo "script start executing at $TIMESTAMP" &>> $LOGFILE 

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "❌ ERROR: $2 ... $R FAILED $N"
        exit 1
    else
        echo -e "✅ SUCCESS: $2 ... $G SUCCESS $N"
    fi
}


 if [ $ID -ne 0 ]; then
        echo -e "❌ ERROR: $2 ... $R PLease run the script with root access $N"
        exit 1
    else
        echo -e "✅ SUCCESS: $2 ... $G You are a root user $N"
    fi


dnf module disable nodejs -y
VALIDATE $? "Diabling ... nodejs" &>> $LOGFILE

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling ... nodejs:20" &>> $LOGFILE

dnf install nodejs -y
VALIDATE $? "Installing ... nodejs" &>> $LOGFILE

useradd roboshop
VALIDATE $? "Adding User ... roboshop " &>> $LOGFILE

mkdir /app
VALIDATE $? "Creating ... Application directory " &>> $LOGFILE


curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
VALIDATE $? "Downloading ... catalogue.zip file from S3 Bucket" &>> $LOGFILE

cd /app 
VALIDATE $? "Changing directory ... app " &>> $LOGFILE

unzip /tmp/catalogue.zip
VALIDATE $? "Unzipping catalogue.zip in /tmp directory " &>> $LOGFILE

cd /app 
VALIDATE $? "Changing directory ... app " &>> $LOGFILE

npm install 
VALIDATE $? "Installing ... npm package ... dependencies " &>> $LOGFILE

#provide absolute path which we pull in instance because catalogue.service exist there
cp /home/ec2-user/devops_practice/roboshop/catalogue-shell/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying ... catalogue.service" &>> $LOGFILE

systemctl daemon-reload
VALIDATE $? "catalogue daemon reload " &>> $LOGFILE


systemctl enable catalogue
VALIDATE $? "Enabling ... catalogue " &>> $LOGFILE


systemctl start catalogue
VALIDATE $? "Starting ... catalogue" &>> $LOGFILE

cp /home/ec2-user/devops_practice/roboshop/mongodb-shell/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying ... mongo.repo to Catalogue" &>> $LOGFILE

dnf install -y mongodb-mongosh
VALIDATE $? "Installing ... mongodb client " &>> $LOGFILE

mongosh --host $MONGODB_HOST </app/schema/catalogue.js
VALIDATE $? "Loading ... Catalogue data into Mongodb"


