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

# Install Redis
dnf install redis -y
VALIDATE $? "Installing Redis"

# Update bind IP in redis.conf to allow external connections
sed -i 's/^bind .*/bind 0.0.0.0/' /etc/redis/redis.conf
VALIDATE $? "Updating bind IP in /etc/redis/redis.conf"

# Enable Redis on boot
systemctl enable redis
VALIDATE $? "Enabling Redis service"

# Start Redis service
systemctl start redis
VALIDATE $? "Starting Redis service"
