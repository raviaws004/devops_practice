#!/bin/bash

ID=$(id -u)


R="\e[31m"
G="\e[32m"
N="\e[0m"


    if [ $1 -ne 0 ]; then
        echo -e "❌ ERROR: $2 ... $R FAILED $N"
        exit 1
    else
        echo -e "✅ SUCCESS: $2 ... $G SUCCESS $N"
    fi



echo "All arguments passed: $@"
