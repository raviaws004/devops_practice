#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date "+%F-%T")
LOGFILE="/tmp/$(basename $0)-$TIMESTAMP.log"

# Constants
APP_USER="roboshop"
APP_DIR="/app"
ZIP_FILE="/tmp/shipping.zip"
ZIP_URL="https://roboshop-builds.s3.amazonaws.com/shipping.zip"
SERVICE_FILE="/etc/systemd/system/shipping.service"
LOCAL_SERVICE_FILE="/home/ec2-user/devops_practice/roboshop/shipping-shell/shipping.service"
MYSQL_HOST="<MYSQL-SERVER-IPADDRESS>"   # 🔴 Replace this with actual IP
MYSQL_PASS="RoboShop@1"

# Colors
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Script started at $TIMESTAMP" &>> $LOGFILE

VALIDATE() {
  if [ $1 -ne 0 ]; then
    echo -e "❌ ERROR: $2 ... $R FAILED $N"
    exit 1
  else
    echo -e "✅ SUCCESS: $2 ... $G SUCCESS $N"
  fi
}

# Root check
if [ $ID -ne 0 ]; then
  echo -e "❌ ERROR: $R Please run this script as root user $N"
  exit 1
else
  echo -e "✅ Running as root user" &>> $LOGFILE
fi

# Install Maven (if not already installed)
dnf list installed maven &> /dev/null
if [ $? -ne 0 ]; then
  dnf install maven -y &>> $LOGFILE
  VALIDATE $? "Installing Maven"
else
  echo -e "✅ Maven already installed ... $Y SKIPPING $N" &>> $LOGFILE
fi

# Create user (if not exists)
id $APP_USER &> /dev/null
if [ $? -ne 0 ]; then
  useradd $APP_USER &>> $LOGFILE
  VALIDATE $? "Creating user $APP_USER"
else
  echo -e "✅ User $APP_USER exists ... $Y SKIPPING $N" &>> $LOGFILE
fi

# Download and extract shipping app
curl -L -o $ZIP_FILE $ZIP_URL &>> $LOGFILE
VALIDATE $? "Downloading shipping.zip"

if [ ! -d $APP_DIR ]; then
  mkdir $APP_DIR &>> $LOGFILE
  VALIDATE $? "Creating $APP_DIR"
else
  echo -e "✅ $APP_DIR already exists ... $Y SKIPPING $N" &>> $LOGFILE
fi

cd $APP_DIR &>> $LOGFILE
unzip -o $ZIP_FILE &>> $LOGFILE
VALIDATE $? "Unzipping shipping.zip"

# Build the project
mvn clean package &>> $LOGFILE
VALIDATE $? "Maven Build"

# Rename JAR
if [ -f target/shipping-1.0.jar ]; then
  mv -f target/shipping-1.0.jar shipping.jar &>> $LOGFILE
  VALIDATE $? "Renaming jar to shipping.jar"
else
  echo -e "❌ JAR file not found ... $R FAILED $N"
  exit 1
fi

# Setup systemd service
if [ -f $LOCAL_SERVICE_FILE ]; then
  cp -f $LOCAL_SERVICE_FILE $SERVICE_FILE &>> $LOGFILE
  VALIDATE $? "Copying service file"
else
  echo -e "❌ Service file $LOCAL_SERVICE_FILE not found ... $R FAILED $N"
  exit 1
fi

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Daemon reload"

systemctl enable shipping &>> $LOGFILE
VALIDATE $? "Enabling shipping service"

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "Restarting shipping service"

# Install MySQL client (if not already installed)
dnf list installed mysql &> /dev/null
if [ $? -ne 0 ]; then
  dnf install mysql -y &>> $LOGFILE
  VALIDATE $? "Installing MySQL client"
else
  echo -e "✅ MySQL client already installed ... $Y SKIPPING $N" &>> $LOGFILE
fi

# Load schema if not already loaded
SCHEMA_LOADED=$(mysql -h $MYSQL_HOST -uroot -p$MYSQL_PASS -e "SHOW DATABASES;" 2>/dev/null | grep -i shipping)
if [ -z "$SCHEMA_LOADED" ]; then
  for file in schema.sql app-user.sql master-data.sql; do
    if [ -f /app/db/$file ]; then
      mysql -h $MYSQL_HOST -uroot -p$MYSQL_PASS < /app/db/$file &>> $LOGFILE
      VALIDATE $? "Loading MySQL file: $file"
    else
      echo -e "❌ File /app/db/$file not found ... $R SKIPPING $N" &>> $LOGFILE
    fi
  done
else
  echo -e "✅ MySQL schema already loaded ... $Y SKIPPING DB load $N" &>> $LOGFILE
fi

echo -e "✅ $G Shipping service setup complete. $N"
