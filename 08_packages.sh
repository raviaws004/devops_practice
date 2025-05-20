#!/bin/bash

ID=$(id -u)


R="\e[31m"
G="\e[32m"
N="\e[0m"


    if [ $ID -ne 0 ]; then
        echo -e "❌ ERROR: $2 ... $R PLease run the script with root access $N"
        exit 1
    else
        echo -e "✅ SUCCESS: $2 ... $G You are a root user $N"
    fi



echo "All arguments passed: $@"
