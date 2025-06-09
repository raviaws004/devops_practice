#!/bin/bash

# Ensure script is run as root
ID=$(id -u)
TIMESTAMP=$(date "+%F-%T")
SCRIPT_NAME=$(basename "$0")
LOGFILE="/tmp/${SCRIPT_NAME}-${TIMESTAMP}.log"

# Color codes
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo -e "${Y}Script started at $TIMESTAMP${N}" &>> "$LOGFILE"

# Function to validate command success
VALIDATE() {
  if [ $1 -ne 0 ]; then
    echo -e "❌ ERROR: $2 ... $R FAILED $N" &>> "$LOGFILE"
    exit 1
  else
    echo -e "✅ SUCCESS: $2 ... $G SUCCESS $N" &>> "$LOGFILE"
  fi
}

# Check if script is run as root
if [ $ID -ne 0 ]; then
  echo -e "❌ ERROR: $R Please run this script as root user. $N" &>> "$LOGFILE"
  exit 1
else
  echo -e "✅ SUCCESS: $G Running as root user. $N" &>> "$LOGFILE"
fi

# Install nginx only if not installed
if ! command -v nginx &>/dev/null; then
  dnf install nginx -y &>> "$LOGFILE"
  VALIDATE $? "Installing Nginx"
else
  echo -e "✅ Nginx already installed ... $Y SKIPPING INSTALL $N" &>> "$LOGFILE"
fi

# Enable nginx service only if not enabled
if ! systemctl is-enabled nginx &>/dev/null; then
  systemctl enable nginx &>> "$LOGFILE"
  VALIDATE $? "Enabling Nginx"
else
  echo -e "✅ Nginx already enabled ... $Y SKIPPING ENABLE $N" &>> "$LOGFILE"
fi

# Start nginx service only if not active
if ! systemctl is-active nginx &>/dev/null; then
  systemctl start nginx &>> "$LOGFILE"
  VALIDATE $? "Starting Nginx"
else
  echo -e "✅ Nginx already running ... $Y SKIPPING START $N" &>> "$LOGFILE"
fi

# Clear existing content only if directory not empty
if [ "$(ls -A /usr/share/nginx/html)" ]; then
  rm -rf /usr/share/nginx/html/* &>> "$LOGFILE"
  VALIDATE $? "Removing existing content"
else
  echo -e "✅ /usr/share/nginx/html already empty ... $Y SKIPPING REMOVE $N" &>> "$LOGFILE"
fi

# Download web.zip only if missing or remote is newer
if [ ! -f /tmp/web.zip ]; then
  curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> "$LOGFILE"
  VALIDATE $? "Downloading content from S3 Bucket"
else
  echo -e "✅ /tmp/web.zip already exists ... $Y SKIPPING DOWNLOAD $N" &>> "$LOGFILE"
fi

# Unzip files into /usr/share/nginx/html, overwrite files
unzip -o /tmp/web.zip -d /usr/share/nginx/html &>> "$LOGFILE"
VALIDATE $? "Unzipping files into /usr/share/nginx/html"

# Restart nginx service to apply changes
systemctl restart nginx &>> "$LOGFILE"
VALIDATE $? "Restarting Nginx"
