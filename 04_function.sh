#!/bin/bash

ID=$(id -u)

# Function to validate command execution
VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo "❌ ERROR: $2"
        exit 1
    else
        echo "✅ SUCCESS: $2"
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
yum install mysql -y
VALIDATE $? "Installing MySQL"
