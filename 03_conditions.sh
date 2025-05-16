#!/bin/bash

ID=$(id -u)

if [ "$ID" -ne 0 ]; then
    echo "Error: Please run the script with root access"
else
    echo "You are a Root User"
fi
