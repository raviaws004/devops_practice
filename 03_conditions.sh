#!/bin/bash

ID=$(id -u)

if [ "$ID" -ne 0 ]; then
    echo "Error: Please run the script with root access"
    exit 1
else
    echo "You are a Root User"
fi

yum install -y mysql

if [ $? -ne 0 ]; then
    echo "ERROR: Installing MYSQL failed"
    exit 1
else 
    echo "Installing MYSQL succeeded!"
fi
