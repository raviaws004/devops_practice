#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date "+%F-%T")
SCRIPT_NAME=$(basename "$0")
LOGFILE="/tmp/${SCRIPT_NAME}-${TIMESTAMP}.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Script started at $TIMESTAMP" &>> "$LOGFILE"

VALIDATE() {
  if [ $1 -ne 0 ]; then
    echo -e "❌ ERROR: $2 ... $R FAILED $N"
    exit 1
  else
    echo -e "✅ SUCCESS: $2 ... $G SUCCESS $N"
  fi
}

# Check for root privileges
if [ "$ID" -ne 0 ]; then
  echo -e "❌ ERROR: Please run the script with root access $R FAILED $N"
  exit 1
else
  echo -e "✅ You are a root user" &>> "$LOGFILE"
fi

# Install required packages only if not installed
for pkg in python3.11 gcc python3-devel unzip; do
  if ! rpm -q $pkg &>/dev/null; then
    dnf install -y $pkg &>> "$LOGFILE"
    VALIDATE $? "Installing package $pkg"
  else
    echo -e "✅ Package $pkg already installed ... $Y SKIPPING $N" &>> "$LOGFILE"
  fi
done

# Create roboshop user if not exists
if ! id roboshop &>/dev/null; then
  useradd roboshop &>> "$LOGFILE"
  VALIDATE $? "Adding user roboshop"
else
  echo -e "✅ User roboshop already exists ... $Y SKIPPING $N" &>> "$LOGFILE"
fi

# Create /app directory if not exists
if [ ! -d /app ]; then
  mkdir -p /app &>> "$LOGFILE"
  VALIDATE $? "Creating /app directory"
else
  echo -e "✅ /app directory already exists ... $Y SKIPPING $N" &>> "$LOGFILE"
fi

# Download payment.zip only if not already downloaded or checksum differs
DOWNLOAD_URL="https://roboshop-builds.s3.amazonaws.com/payment.zip"
ZIP_FILE="/tmp/payment.zip"

if [ ! -f "$ZIP_FILE" ]; then
  curl -L -o "$ZIP_FILE" "$DOWNLOAD_URL" &>> "$LOGFILE"
  VALIDATE $? "Downloading payment.zip from S3"
else
  echo -e "✅ $ZIP_FILE already exists ... $Y SKIPPING download $N" &>> "$LOGFILE"
fi

# Unzip payment.zip into /app
unzip -o "$ZIP_FILE" -d /app &>> "$LOGFILE"
VALIDATE $? "Unzipping payment.zip into /app"

# Install pip dependencies with python3.11 - do it only if requirements.txt exists
if [ -f /app/requirements.txt ]; then
  pip3.11 install -r /app/requirements.txt &>> "$LOGFILE"
  VALIDATE $? "Installing pip packages from requirements.txt"
else
  echo -e "❌ ERROR: /app/requirements.txt not found $R FAILED $N"
  exit 1
fi

# Copy payment.service only if changed or not exists
SERVICE_FILE_SRC="/home/ec2-user/devops_practice/roboshop/payment-shell/payment.service"
SERVICE_FILE_DEST="/etc/systemd/system/payment.service"

if [ ! -f "$SERVICE_FILE_DEST" ] || ! cmp -s "$SERVICE_FILE_SRC" "$SERVICE_FILE_DEST"; then
  cp "$SERVICE_FILE_SRC" "$SERVICE_FILE_DEST" &>> "$LOGFILE"
  VALIDATE $? "Copying payment.service to systemd directory"
else
  echo -e "✅ payment.service already up to date ... $Y SKIPPING copy $N" &>> "$LOGFILE"
fi

systemctl daemon-reload &>> "$LOGFILE"
VALIDATE $? "Reloading systemd daemon"

# Enable service only if not already enabled
if ! systemctl is-enabled payment &>/dev/null; then
  systemctl enable payment &>> "$LOGFILE"
  VALIDATE $? "Enabling payment service"
else
  echo -e "✅ payment service already enabled ... $Y SKIPPING enable $N" &>> "$LOGFILE"
fi

# Start or restart the service if not running or for config update
if systemctl is-active payment &>/dev/null; then
  systemctl restart payment &>> "$LOGFILE"
  VALIDATE $? "Restarting payment service"
else
  systemctl start payment &>> "$LOGFILE"
  VALIDATE $? "Starting payment service"
fi

echo -e "✅ $G Payment setup completed successfully $N"
