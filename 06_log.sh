#!/bin/bash

ID=$(id -u)

TIMESTAMP=$(date "+%F-%T")  # Safe timestamp format
LOGFILE="/tmp/$(basename $0)-$TIMESTAMP.log"

# Function to validate command execution
VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo "❌ ERROR: $2" | tee -a $LOGFILE
        exit 1
    else
        echo "✅ SUCCESS: $2" | tee -a $LOGFILE
    fi
}

# Check for root access
if [ $ID -ne 0 ]; then 
    echo "❌ ERROR: Please run this script with root access" | tee -a $LOGFILE
    exit 1
else 
    echo "✅ You are a Root User" | tee -a $LOGFILE
fi

# Install MySQL
echo "Installing MySQL..." | tee -a $LOGFILE
yum install mysql -y &>> $LOGFILE
VALIDATE $? "Installing MySQL"

# Install Git
echo "Installing Git..." | tee -a $LOGFILE
yum install git -y &>> $LOGFILE
VALIDATE $? "Installing Git"
