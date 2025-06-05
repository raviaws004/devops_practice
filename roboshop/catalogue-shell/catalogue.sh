#!/bin/bash

set -e  # Exit immediately if a command exits with non-zero status

ID=$(id -u)
TIMESTAMP=$(date "+%F-%T")  # YYYY-MM-DD-HH:MM:SS
LOGFILE="/tmp/$(basename "$0")-$TIMESTAMP.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

MONGODB_HOST="172.31.32.244"

echo -e "${Y}Script started at $TIMESTAMP${N}" | tee -a "$LOGFILE"

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "❌ ERROR: $2 ... ${R}FAILED${N}" | tee -a "$LOGFILE"
        exit 1
    else
        echo -e "✅ SUCCESS: $2 ... ${G}SUCCESS${N}" | tee -a "$LOGFILE"
    fi
}

# Root user check
if [ "$ID" -ne 0 ]; then
    echo -e "❌ ERROR: Please run the script with root access${N}" | tee -a "$LOGFILE"
    exit 1
else
    echo -e "✅ You are running as root user${N}" | tee -a "$LOGFILE"
fi

dnf module disable nodejs -y &>> "$LOGFILE"
VALIDATE $? "Disabling nodejs module"

dnf module enable nodejs:20 -y &>> "$LOGFILE"
VALIDATE $? "Enabling nodejs:20 module"

dnf install nodejs -y &>> "$LOGFILE"
VALIDATE $? "Installing nodejs"

# Check if user roboshop exists, else add
if id roboshop &>/dev/null; then
    echo -e "✅ User roboshop already exists ... ${Y}SKIPPING${N}" | tee -a "$LOGFILE"
else
    useradd roboshop &>> "$LOGFILE"
    VALIDATE $? "Adding user roboshop"
fi

mkdir -p /app &>> "$LOGFILE"
VALIDATE $? "Creating /app directory"

chown roboshop:roboshop /app &>> "$LOGFILE"
VALIDATE $? "Setting ownership for /app to roboshop"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> "$LOGFILE"
VALIDATE $? "Downloading catalogue.zip"

cd /app &>> "$LOGFILE"
VALIDATE $? "Changing directory to /app"

unzip -o /tmp/catalogue.zip &>> "$LOGFILE"
VALIDATE $? "Unzipping catalogue.zip"

npm install &>> "$LOGFILE"
VALIDATE $? "Installing npm dependencies"

# Check if service file exists before copying
SERVICE_SRC="/home/ec2-user/devops_practice/roboshop/catalogue-shell/catalogue.service"
if [ -f "$SERVICE_SRC" ]; then
    cp "$SERVICE_SRC" /etc/systemd/system/catalogue.service &>> "$LOGFILE"
    VALIDATE $? "Copying catalogue.service"
else
    echo -e "❌ ERROR: Service file $SERVICE_SRC not found${N}" | tee -a "$LOGFILE"
    exit 1
fi

systemctl daemon-reload &>> "$LOGFILE"
VALIDATE $? "Reloading systemd daemon"

systemctl enable catalogue &>> "$LOGFILE"
VALIDATE $? "Enabling catalogue service"

systemctl restart catalogue &>> "$LOGFILE"
VALIDATE $? "Starting/restarting catalogue service"

# Check if mongo.repo file exists before copying
MONGO_REPO_SRC="/home/ec2-user/devops_practice/roboshop/mongodb-shell/mongo.repo"
if [ -f "$MONGO_REPO_SRC" ]; then
    cp "$MONGO_REPO_SRC" /etc/yum.repos.d/mongo.repo &>> "$LOGFILE"
    VALIDATE $? "Copying mongo.repo"
else
    echo -e "❌ ERROR: mongo.repo file $MONGO_REPO_SRC not found${N}" | tee -a "$LOGFILE"
    exit 1
fi

dnf install -y mongodb-mongosh &>> "$LOGFILE"
VALIDATE $? "Installing mongodb client (mongosh)"

mongosh --host "$MONGODB_HOST" </app/schema/catalogue.js &>> "$LOGFILE"
VALIDATE $? "Loading catalogue data into MongoDB"

echo -e "${G}Script completed successfully!${N}" | tee -a "$LOGFILE"
