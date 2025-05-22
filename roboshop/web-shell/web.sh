#!/bin/bash

# Ensure script is run as root
ID=$(id -u)
TIMESTAMP=$(date "+%F-%T")
LOGFILE="/tmp/$(basename $0)-$TIMESTAMP.log"

# Redirect all output (stdout and stderr) to log file
exec &> "$LOGFILE"

# Color codes
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo -e "${Y}Script started at $TIMESTAMP${N}"

# Function to validate command success
VALIDATE() {
  if [ $1 -ne 0 ]; then
    echo -e "❌ ERROR: $2 ... $R FAILED $N"
    exit 1
  else
    echo -e "✅ SUCCESS: $2 ... $G SUCCESS $N"
  fi
}

# Check if script is run as root
if [ $ID -ne 0 ]; then
  echo -e "❌ ERROR: $R Please run this script as root user. $N"
  exit 1
else
  echo -e "✅ SUCCESS: $G Running as root user. $N"
fi

echo -e "${Y}Installing Nginx${N}"
dnf install nginx -y
VALIDATE $? "Installing Nginx"

echo -e "${Y}Enabling Nginx Service${N}"
systemctl enable nginx
VALIDATE $? "Enabling Nginx"

echo -e "${Y}Starting Nginx Service${N}"
systemctl start nginx
VALIDATE $? "Starting Nginx"

echo -e "${Y}Cleaning existing content in /usr/share/nginx/html${N}"
rm -rf /usr/share/nginx/html/*
VALIDATE $? "Removing default Nginx content"

echo -e "${Y}Downloading frontend application code (web.zip)${N}"
curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip
VALIDATE $? "Downloading web.zip"

echo -e "${Y}Unzipping web.zip${N}"
unzip -o /tmp/web.zip -d /usr/share/nginx/html/
VALIDATE $? "Extracting web.zip to /usr/share/nginx/html"

echo -e "${Y}Restarting Nginx service to apply changes${N}"
systemctl restart nginx
VALIDATE $? "Restarting Nginx"

echo -e "${G}Frontend setup completed successfully!${N}"
