#!/bin/bash

# Ensure script is run as root
ID=$(id -u)
TIMESTAMP=$(date "+%F-%T")
LOGFILE="/tmp/$(basename $0)-$TIMESTAMP.log"

# Redirect all output (stdout and stderr) to log file


# Color codes
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo -e "${Y}Script started at $TIMESTAMP${N}" &>> $LOGFILE

# Function to validate command success
VALIDATE() {
  if [ $1 -ne 0 ]; then
    echo -e "❌ ERROR: $2 ... $R FAILED $N" &>> $LOGFILE
    exit 1
  else
    echo -e "✅ SUCCESS: $2 ... $G SUCCESS $N" &>> $LOGFILE
  fi
}

# Check if script is run as root
if [ $ID -ne 0 ]; then
  echo -e "❌ ERROR: $R Please run this script as root user. $N" &>> $LOGFILE
  exit 1
else
  echo -e "✅ SUCCESS: $G Running as root user. $N" &>> $LOGFILE
fi

dnf install nginx -y &>> $LOGFILE
VALIDATE $? "Installing ... Nginx "

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "Enabling ... Nginx "

systemctl start nginx &>> $LOGFILE
VALIDATE $? "Staring ... Nginx "

rm -rf /usr/share/nginx/html/* &>> $LOGFILE
VALIDATE $? "Removing existing content ... "

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
VALIDATE $? "Downloading content from S3 Bucket "


unzip /tmp/web.zip &>> $LOGFILE
VALIDATE $? "Unziping Files in temp dir ... "

 
systemctl restart nginx &>> $LOGFILE
VALIDATE $? "Restarting ... Nginx "
