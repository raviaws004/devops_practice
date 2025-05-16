#!/bin/bash

ID=$(id -u)

VALIDATE() {
}
if [ $ID -ne 0 ]
then 
    echo "ERROR:: PLease run this script with root access"
    exit 1 # you can give other than 0

else 
    echo "You are a Root User"

fi

yum install mysql -y

