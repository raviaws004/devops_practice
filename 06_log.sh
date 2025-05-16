#!/bin/bash

ID=$(id -u)

TIMESTAMP=$(date "+%F-%T")  # %F = YYYY-MM-DD, %T = HH:MM:SS
LOGFILE="/tmp/$(basename $0)-$TIMESTAMP.log"



# Function to validate command execution
VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "\e[31m❌ FAILED: $2\e[0m"  # Red text
        exit 1
    else
        echo -e "\e[32m✅ SUCCESS: $2\e[0m"  # Green text
    fi
}

# Check for root access
if [ $ID -ne 0 ]; then 
    echo "❌ ERROR: Please run this script with root access"
    exit 1
else 
    echo "✅ You are a Root User"
fi

# Install MySQL
yum install mysql -y &>> $LOGFILE

VALIDATE $? "Installing MySQL"


yum install git  &>> $LOGFILE

VALIDATE $? "Installing Git"