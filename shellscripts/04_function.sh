#!/bin/bash

ID=$(id -u)


R="\e[31m"
G="\e[32m"
N="\e[0m"

# Function to validate command execution
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
    echo -e "$R ❌ ERROR: Please run this script with root access $N"
    exit 1
else 
    echo "✅ You are a Root User"
fi

# Install MySQL
yum install mysql -y &>> $LOGFILE

VALIDATE $? "Installing MySQL"


yum install git  &>> $LOGFILE

VALIDATE $? "Installing Git"