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
        echo -e "✅ SUCCESS: $2 ... $G You are a root user $N"
    fi


dnf install python3.11 gcc python3-devel -y &>> $LOGFILE
VALIDATE $? "Installing... Python 3.6" 


id roboshop
if [ $? -ne -0 ]
then 

    useradd roboshop &>> $LOGFILE
    VALIDATE $? "Adding User ... roboshop " 
else echo -e "roboshop user already exist ... $Y SKIPPING $N"
fi


mkdir -p /app &>> $LOGFILE
VALIDATE $? "Creating ... Application directory " 


curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
VALIDATE $? "Downloading ... payment.zip file from S3 Bucket" 

cd /app &>> $LOGFILE
VALIDATE $? "Changing directory ... app " 

#unzip /tmp/payment.zip &>> $LOGFILE
unzip -o /tmp/payment.zip &>> $LOGFILE
VALIDATE $? "Unzipping payment.zip in /tmp directory " 

cd /app &>> $LOGFILE
VALIDATE $? "Changing directory ... app " 

pip3.11 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "Installing ... pip package ... dependencies " 

#provide absolute path which we pull in instance because payment.service exist there
cp /home/ec2-user/devops_practice/roboshop/payment-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "Copying ... payment.service" 

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "payment daemon reload " 


systemctl enable payment &>> $LOGFILE
VALIDATE $? "Enabling ... payment "


systemctl start payment &>> $LOGFILE
VALIDATE $? "Starting ... payment" 



