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


dnf install redis -y &>> $LOGFILE
VALIDATE $? "Installing ... redis"


# Update bind IP in redis.conf
#sed -i '127.0.0.1/0.0.0.0 /g' /etc/redis.conf &>> $LOGFILE   --> invalid syntax 
grep bindIp /etc/redis.conf &>> $LOGFILE
sed -i 's/127\.0\.0\.1/0.0.0.0/' /etc/redis.conf &>> $LOGFILE
VALIDATE $? "Updating bind IP in redis.conf"
grep bindIp /etc/redis.conf &>> $LOGFILE

systemctl enable redis &>> $LOGFILE
VALIDATE $? "Enabling ... redis "


systemctl start redis &>> $LOGFILE
VALIDATE $? "Starting ... redis" 