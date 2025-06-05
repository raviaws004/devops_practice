#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date "+%F-%T")  # %F = YYYY-MM-DD, %T = HH:MM:SS
SCRIPT_NAME=$(basename "$0")
LOGFILE="/tmp/${SCRIPT_NAME}-${TIMESTAMP}.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

MONGODB_HOST=172.31.46.203

echo "Script start executing at $TIMESTAMP" &>> "$LOGFILE"

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "❌ ERROR: $2 ... $R FAILED $N"
        exit 1
    else
        echo -e "✅ SUCCESS: $2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]; then
    echo -e "❌ ERROR: Please run the script with root access $R FAILED $N"
    exit 1
else
    echo -e "✅ You are a root user" &>> "$LOGFILE"
fi

# Disable nodejs module only if enabled
if dnf module list nodejs | grep -q 'nodejs.*\[e\]'; then
    dnf module disable nodejs -y &>> "$LOGFILE"
    VALIDATE $? "Disabling nodejs module"
else
    echo -e "✅ nodejs module already disabled ... $Y SKIPPING $N" &>> "$LOGFILE"
fi

# Enable nodejs:20 module only if not enabled
if ! dnf module list nodejs | grep -q 'nodejs:20.*\[e\]'; then
    dnf module enable nodejs:20 -y &>> "$LOGFILE"
    VALIDATE $? "Enabling nodejs:20 module"
else
    echo -e "✅ nodejs:20 module already enabled ... $Y SKIPPING $N" &>> "$LOGFILE"
fi

# Install nodejs if not installed
if ! command -v node &>/dev/null; then
    dnf install nodejs -y &>> "$LOGFILE"
    VALIDATE $? "Installing nodejs"
else
    echo -e "✅ nodejs already installed ... $Y SKIPPING $N" &>> "$LOGFILE"
fi

# Add roboshop user if not exists
if ! id roboshop &>/dev/null; then
    useradd roboshop &>> "$LOGFILE"
    VALIDATE $? "Adding User roboshop"
else
    echo -e "✅ roboshop user already exists ... $Y SKIPPING $N" &>> "$LOGFILE"
fi

# Create /app directory if missing
mkdir -p /app &>> "$LOGFILE"
VALIDATE $? "Creating /app directory"

# Download user.zip only if missing or remote is newer (using curl -z)
if [ ! -f /tmp/user.zip ]; then
    curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> "$LOGFILE"
    VALIDATE $? "Downloading user.zip from S3 Bucket"
else
    echo -e "✅ /tmp/user.zip already exists ... $Y SKIPPING DOWNLOAD $N" &>> "$LOGFILE"
fi

cd /app || { echo -e "❌ ERROR: Could not cd /app"; exit 1; }
VALIDATE $? "Changing directory to /app"

# Unzip user.zip, overwrite existing files (safe to run multiple times)
unzip -o /tmp/user.zip &>> "$LOGFILE"
VALIDATE $? "Unzipping user.zip into /app"

# Install npm dependencies
npm install &>> "$LOGFILE"
VALIDATE $? "Installing npm packages"

# Copy user.service only if missing or changed
SERVICE_SRC="/home/ec2-user/devops_practice/roboshop/user-shell/user.service"
SERVICE_DST="/etc/systemd/system/user.service"

if [ ! -f "$SERVICE_DST" ] || ! cmp -s "$SERVICE_SRC" "$SERVICE_DST"; then
    cp "$SERVICE_SRC" "$SERVICE_DST" &>> "$LOGFILE"
    VALIDATE $? "Copying user.service"
else
    echo -e "✅ user.service already up to date ... $Y SKIPPING COPY $N" &>> "$LOGFILE"
fi

systemctl daemon-reload &>> "$LOGFILE"
VALIDATE $? "Reloading systemd daemon"

# Enable user service only if not enabled
if ! systemctl is-enabled user &>/dev/null; then
    systemctl enable user &>> "$LOGFILE"
    VALIDATE $? "Enabling user service"
else
    echo -e "✅ user service already enabled ... $Y SKIPPING ENABLE $N" &>> "$LOGFILE"
fi

# Start user service only if not running
if systemctl is-active --quiet user; then
    echo -e "✅ user service already running ... $Y SKIPPING START $N" &>> "$LOGFILE"
else
    systemctl start user &>> "$LOGFILE"
    VALIDATE $? "Starting user service"
fi

# Copy mongo.repo only if missing or changed
MONGO_REPO_SRC="/home/ec2-user/devops_practice/roboshop/mongodb-shell/mongo.repo"
MONGO_REPO_DST="/etc/yum.repos.d/mongo.repo"

if [ ! -f "$MONGO_REPO_DST" ] || ! cmp -s "$MONGO_REPO_SRC" "$MONGO_REPO_DST"; then
    cp "$MONGO_REPO_SRC" "$MONGO_REPO_DST" &>> "$LOGFILE"
    VALIDATE $? "Copying mongo.repo"
else
    echo -e "✅ mongo.repo already up to date ... $Y SKIPPING COPY $N" &>> "$LOGFILE"
fi

# Install mongodb-mongosh client if not installed
if ! command -v mongosh &>/dev/null; then
    dnf install -y mongodb-mongosh &>> "$LOGFILE"
    VALIDATE $? "Installing mongodb client"
else
    echo -e "✅ mongodb client already installed ... $Y SKIPPING INSTALL $N" &>> "$LOGFILE"
fi

# Load user data into MongoDB only once (using marker file)
MARKER_FILE="/tmp/user_data_loaded"

if [ ! -f "$MARKER_FILE" ]; then
    mongosh --host "$MONGODB_HOST" </app/schema/user.js &>> "$LOGFILE"
    VALIDATE $? "Loading user data into MongoDB"
    touch "$MARKER_FILE"
else
    echo -e "✅ User data already loaded into MongoDB ... $Y SKIPPING LOAD $N" &>> "$LOGFILE"
fi
