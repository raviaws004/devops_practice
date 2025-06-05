#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date "+%F-%T")
LOGFILE="/tmp/$(basename $0)-$TIMESTAMP.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "MySQL Setup started at $TIMESTAMP" &>> $LOGFILE

VALIDATE() {
  if [ $1 -ne 0 ]; then
    echo -e "❌ ERROR: $2 ... $R FAILED $N"
    exit 1
  else
    echo -e "✅ SUCCESS: $2 ... $G SUCCESS $N"
  fi
}

# Check for root
if [ $ID -ne 0 ]; then
  echo -e "❌ ERROR: Please run this script as root or with sudo"
  exit 1
fi

# Step 1: Check and install MySQL server
dnf list installed mysql-server &>> $LOGFILE
if [ $? -ne 0 ]; then
  dnf install mysql-server -y &>> $LOGFILE
  VALIDATE $? "Installing MySQL Server"
else
  echo -e "✅ $Y MySQL Server already installed, skipping installation $N"
fi

# Step 2: Enable mysqld service if not already enabled
systemctl is-enabled mysqld &>> $LOGFILE
if [ $? -ne 0 ]; then
  systemctl enable mysqld &>> $LOGFILE
  VALIDATE $? "Enabling mysqld service"
else
  echo -e "✅ $Y mysqld already enabled $N"
fi

# Step 3: Start mysqld if not running
systemctl is-active mysqld &>> $LOGFILE
if [ $? -ne 0 ]; then
  systemctl start mysqld &>> $LOGFILE
  VALIDATE $? "Starting mysqld service"
else
  echo -e "✅ $Y mysqld service already running $N"
fi

# Step 4: Check if root password is already set
mysql -u root -pRoboShop@1 -e "SELECT 1;" &>> $LOGFILE
if [ $? -ne 0 ]; then
  echo "Setting MySQL root password..." &>> $LOGFILE
  mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
  VALIDATE $? "Setting MySQL root password"
else
  echo -e "✅ $Y MySQL root password already set, skipping password configuration $N"
fi

# Step 5: Final login test
mysql -u root -pRoboShop@1 -e "SELECT VERSION();" &>> $LOGFILE
VALIDATE $? "MySQL login test with root password"

echo -e "✅ $G MySQL setup complete. Root password is: RoboShop@1 $N"
