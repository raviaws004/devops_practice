#!/bin/bash

ID=$(id -u)

TIMESTAMP=$(date "+%F-%T")  # %F = YYYY-MM-DD, %T = HH:MM:SS
LOGFILE="/tmp/$0-$TIMESTAMP.log"


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


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
        echo -e "✅ SUCCESS: $2 ... $G You are a root cart $N"
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
    VALIDATE $? "Adding cart ... roboshop " 
else echo -e "roboshop cart already exist ... $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "Creating ... Application directory " 


curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE $? "Downloading ... cart.zip file from S3 Bucket" 

cd /app &>> $LOGFILE
VALIDATE $? "Changing directory ... app " 

#unzip /tmp/cart.zip &>> $LOGFILE
unzip -o /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "Unzipping cart.zip in /tmp directory " 

cd /app &>> $LOGFILE
VALIDATE $? "Changing directory ... app " 

npm install &>> $LOGFILE
VALIDATE $? "Installing ... npm package ... dependencies " 

#provide absolute path which we pull in instance because cart.service exist there
cp /home/ec2-cart/devops_practice/roboshop/cart-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE
VALIDATE $? "Copying ... cart.service" 

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "cart daemon reload " 


systemctl enable cart &>> $LOGFILE
VALIDATE $? "Enabling ... cart "


systemctl start cart &>> $LOGFILE
VALIDATE $? "Starting ... cart" 






