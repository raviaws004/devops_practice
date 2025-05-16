#!/bin/bash

ID=$(id -u)

if [ "$ID" -ne 0 ]; then
    echo "Error: Please run the script with root access"
else
    echo "You are a Root User"
fi

yum install mysql

if [$? -ne 0]
then 
    echo "ERROR:: Installing MYSQL is failed"
    exit 1
else 
    echo "Installing MYSQL is Success!!!"
fi