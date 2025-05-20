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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copied MOngoDB"