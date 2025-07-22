#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date "+%F-%T")
SCRIPT_NAME=$(basename $0)
LOGFILE="/tmp/${SCRIPT_NAME}-${TIMESTAMP}.log"

# Color codes
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Script started at $TIMESTAMP" &>> $LOGFILE

# Validation function
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

# Copy MongoDB repo file only if it doesn't exist
if [ ! -f /etc/yum.repos.d/mongo.repo ]; then
  cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
  VALIDATE $? "Copying mongo.repo to yum.repos.d"
else
  echo -e "✅ mongo.repo already exists ... $Y SKIPPING $N" &>> $LOGFILE
fi

# Install MongoDB only if not already installed
dnf list installed mongodb-org &> /dev/null
if [ $? -ne 0 ]; then
  dnf install mongodb-org -y &>> $LOGFILE
  VALIDATE $? "Installing MongoDB"
else
  echo -e "✅ MongoDB already installed ... $Y SKIPPING $N" &>> $LOGFILE
fi

# Enable mongod if not already enabled
systemctl is-enabled mongod &> /dev/null
if [ $? -ne 0 ]; then
  systemctl enable mongod &>> $LOGFILE
  VALIDATE $? "Enabling MongoDB"
else
  echo -e "✅ MongoDB already enabled ... $Y SKIPPING $N" &>> $LOGFILE
fi

# Start mongod if not already active
systemctl is-active mongod &> /dev/null
if [ $? -ne 0 ]; then
  systemctl start mongod &>> $LOGFILE
  VALIDATE $? "Starting MongoDB"
else
  echo -e "✅ MongoDB already running ... $Y SKIPPING $N" &>> $LOGFILE
fi

# Update bind IP in mongod.conf only if required
grep -q "bindIp: 0.0.0.0" /etc/mongod.conf
if [ $? -ne 0 ]; then
  sed -i 's/127\.0\.0\.1/0.0.0.0/' /etc/mongod.conf &>> $LOGFILE
  VALIDATE $? "Updating bindIp to 0.0.0.0 in mongod.conf"
else
  echo -e "✅ bindIp already set to 0.0.0.0 ... $Y SKIPPING $N" &>> $LOGFILE
fi

# Restart mongod to apply config changes
systemctl restart mongod &>> $LOGFILE
VALIDATE $? "Restarting MongoDB service"

echo -e "✅ $G MongoDB setup completed successfully. $N"
