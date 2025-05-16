#!/bin/bash

ID=$(id -u)

TIMESTAMP=$(date "+%F-%T")  # %F = YYYY-MM-DD, %T = HH:MM:SS
LOGFILE="/tmp/$(basename $0)-$TIMESTAMP.log"

R="\e[31m"
G="\e[32m"
N="\e[0m"

# Function to validate command execution
VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo "❌ ERROR: $2 ... $R FAILED $N"
        exit 1
    else
        echo "✅ SUCCESS: $2 ... $G SUCESS $N"
    fi
}

# Check for root access
if [ $ID -ne 0 ]; then 
    echo "$R ❌ ERROR: Please run this script with root access $N"
    exit 1
else 
    echo "✅ You are a Root User"
fi

# Install MySQL
yum install mysql -y &>> $LOGFILE

VALIDATE $? "Installing MySQL"


yum install git  &>> $LOGFILE

VALIDATE $? "Installing Git"