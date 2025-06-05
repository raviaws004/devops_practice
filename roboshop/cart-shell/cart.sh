#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date "+%F-%T")
SCRIPT_NAME=$(basename $0)
LOGFILE="/tmp/${SCRIPT_NAME}-${TIMESTAMP}.log"

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

# Check for root access
if [ $ID -ne 0 ]; then
  echo -e "❌ ERROR: Please run the script with root access"
  exit 1
else
  echo -e "✅ Running as root user" &>> $LOGFILE
fi

# Disable existing NodeJS module if not already disabled
dnf module list nodejs | grep -q "nodejs.*\[e\]"
if [ $? -eq 0 ]; then
  dnf module disable nodejs -y &>> $LOGFILE
  VALIDATE $? "Disabling default NodeJS module"
else
  echo -e "✅ NodeJS module already disabled ... $Y SKIPPING $N" &>> $LOGFILE
fi

# Enable NodeJS 20 module only if not already enabled
dnf module list nodejs | grep -q "nodejs.*20.*\[e\]"
if [ $? -ne 0 ]; then
  dnf module enable nodejs:20 -y &>> $LOGFILE
  VALIDATE $? "Enabling NodeJS 20 module"
else
  echo -e "✅ NodeJS 20 already enabled ... $Y SKIPPING $N" &>> $LOGFILE
fi

# Install NodeJS if not installed
dnf list installed nodejs &> /dev/null
if [ $? -ne 0 ]; then
  dnf install nodejs -y &>> $LOGFILE
  VALIDATE $? "Installing NodeJS"
else
  echo -e "✅ NodeJS already installed ... $Y SKIPPING $N" &>> $LOGFILE
fi

# Add roboshop user if not exists
id roboshop &> /dev/null
if [ $? -ne 0 ]; then
  useradd roboshop &>> $LOGFILE
  VALIDATE $? "Adding user 'roboshop'"
else
  echo -e "✅ User 'roboshop' already exists ... $Y SKIPPING $N" &>> $LOGFILE
fi

# Create /app directory
if [ ! -d /app ]; then
  mkdir -p /app &>> $LOGFILE
  VALIDATE $? "Creating /app directory"
else
  echo -e "✅ /app directory already exists ... $Y SKIPPING $N" &>> $LOGFILE
fi

# Download and unzip cart.zip
curl -s -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE $? "Downloading cart.zip"

cd /app &>> $LOGFILE
unzip -o /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "Unzipping cart.zip to /app"

# Install npm dependencies
npm install &>> $LOGFILE
VALIDATE $? "Installing npm packages"

# Copy systemd service file
SERVICE_FILE="/etc/systemd/system/cart.service"
SOURCE_FILE="/home/ec2-user/devops_practice/roboshop/cart-shell/cart.service"

if [ -f "$SOURCE_FILE" ]; then
  cp -f "$SOURCE_FILE" "$SERVICE_FILE" &>> $LOGFILE
  VALIDATE $? "Copying cart.service file"
else
  echo -e "❌ ERROR: Source service file $SOURCE_FILE not found ... $R FAILED $N"
  exit 1
fi

# Enable and start cart service
systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Systemd daemon reload"

systemctl enable cart &>> $LOGFILE
VALIDATE $? "Enabling cart service"

systemctl restart cart &>> $LOGFILE
VALIDATE $? "Restarting cart service"

echo -e "✅ $G Cart component setup completed successfully. $N"
