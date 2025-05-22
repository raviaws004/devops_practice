#!/bin/bash

ID=$(id -u)

TIMESTAMP=$(date "+%F-%T")  # %F = YYYY-MM-DD, %T = HH:MM:SS
LOGFILE="/tmp/$0-$TIMESTAMP.log"


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

MONGODB_HOST=172.31.46.203

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


dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "Diabling ... nodejs" 

dnf module enable nodejs:20 -y &>> $LOGFILE
VALIDATE $? "Enabling ... nodejs:20"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing ... nodejs" 


id roboshop
if [ $? -ne -0 ]
then 

    useradd roboshop &>> $LOGFILE
    VALIDATE $? "Adding User ... roboshop " 
else echo -e "roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "Creating ... Application directory " 


curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
VALIDATE $? "Downloading ... user.zip file from S3 Bucket" 

cd /app &>> $LOGFILE
VALIDATE $? "Changing directory ... app " 

#unzip /tmp/user.zip &>> $LOGFILE
unzip -o /tmp/user.zip &>> $LOGFILE
VALIDATE $? "Unzipping user.zip in /tmp directory " 

cd /app &>> $LOGFILE
VALIDATE $? "Changing directory ... app " 

npm install &>> $LOGFILE
VALIDATE $? "Installing ... npm package ... dependencies " 

#provide absolute path which we pull in instance because user.service exist there
cp /home/ec2-user/devops_practice/roboshop/user-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE
VALIDATE $? "Copying ... user.service" 

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "user daemon reload " 


systemctl enable user &>> $LOGFILE
VALIDATE $? "Enabling ... user "


systemctl start user &>> $LOGFILE
VALIDATE $? "Starting ... user" 

cp /home/ec2-user/devops_practice/roboshop/mongodb-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copying ... mongo.repo to user" 

dnf install -y mongodb-mongosh &>> $LOGFILE
VALIDATE $? "Installing ... mongodb client " 

mongosh --host $MONGODB_HOST </app/schema/user.js &>> $LOGFILE
VALIDATE $? "Loading ... user data into Mongodb" 


