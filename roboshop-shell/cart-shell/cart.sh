#!/bin/bash
set -euo pipefail

ID=$(id -u)
TIMESTAMP=$(date "+%F-%T")
SCRIPT_NAME=$(basename "$0")
LOGFILE="/tmp/${SCRIPT_NAME}-${TIMESTAMP}.log"

# Colors
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo -e "${Y}Script started at $TIMESTAMP${N}" | tee -a "$LOGFILE"

VALIDATE() {
  if [ $1 -ne 0 ]; then
    echo -e "❌ ERROR: $2 ... ${R}FAILED${N}" | tee -a "$LOGFILE"
    exit 1
  else
    echo -e "✅ SUCCESS: $2 ... ${G}SUCCESS${N}" | tee -a "$LOGFILE"
  fi
}

# Check for root access
if [ "$ID" -ne 0 ]; then
  echo -e "❌ ERROR: Please run the script with root access" | tee -a "$LOGFILE"
  exit 1
else
  echo -e "✅ Running as root user" | tee -a "$LOGFILE"
fi

# Disable existing NodeJS module if not already disabled
if dnf module list nodejs | grep -q "nodejs.*\[e\]"; then
  dnf module disable nodejs -y &>> "$LOGFILE"
  VALIDATE $? "Disabling default NodeJS module"
else
  echo -e "✅ NodeJS module already disabled ... ${Y}SKIPPING${N}" | tee -a "$LOGFILE"
fi

# Enable NodeJS 20 module only if not already enabled
if ! dnf module list nodejs | grep -q "nodejs.*20.*\[e\]"; then
  dnf module enable nodejs:20 -y &>> "$LOGFILE"
  VALIDATE $? "Enabling NodeJS 20 module"
else
  echo -e "✅ NodeJS 20 already enabled ... ${Y}SKIPPING${N}" | tee -a "$LOGFILE"
fi

# Install NodeJS if not installed
if ! dnf list installed nodejs &> /dev/null; then
  dnf install nodejs -y &>> "$LOGFILE"
  VALIDATE $? "Installing NodeJS"
else
  echo -e "✅ NodeJS already installed ... ${Y}SKIPPING${N}" | tee -a "$LOGFILE"
fi

# Add roboshop user if not exists
if ! id roboshop &> /dev/null; then
  useradd roboshop &>> "$LOGFILE"
  VALIDATE $? "Adding user 'roboshop'"
else
  echo -e "✅ User 'roboshop' already exists ... ${Y}SKIPPING${N}" | tee -a "$LOGFILE"
fi

# Create /app directory and set ownership
if [ ! -d /app ]; then
  mkdir -p /app &>> "$LOGFILE"
  VALIDATE $? "Creating /app directory"
else
  echo -e "✅ /app directory already exists ... ${Y}SKIPPING${N}" | tee -a "$LOGFILE"
fi

chown -R roboshop:roboshop /app &>> "$LOGFILE"
VALIDATE $? "Setting ownership of /app to roboshop"

# Download cart.zip (always overwrite to ensure latest)
curl -s -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> "$LOGFILE"
VALIDATE $? "Downloading cart.zip"

# Clean /app before unzip to avoid stale files
rm -rf /app/* &>> "$LOGFILE"

cd /app
VALIDATE $? "Changing directory to /app"

unzip -o /tmp/cart.zip &>> "$LOGFILE"
VALIDATE $? "Unzipping cart.zip to /app"

# Set ownership after unzip
chown -R roboshop:roboshop /app &>> "$LOGFILE"
VALIDATE $? "Setting ownership of /app contents to roboshop"

# Run npm install as roboshop user to avoid permission issues
sudo -u roboshop npm install &>> "$LOGFILE"
VALIDATE $? "Installing npm packages as roboshop user"

# Copy systemd service file
SERVICE_FILE="/etc/systemd/system/cart.service"
SOURCE_FILE="/home/ec2-user/devops_practice/roboshop/cart-shell/cart.service"

if [ -f "$SOURCE_FILE" ]; then
  cp -f "$SOURCE_FILE" "$SERVICE_FILE" &>> "$LOGFILE"
  VALIDATE $? "Copying cart.service file"
else
  echo -e "❌ ERROR: Source service file $SOURCE_FILE not found ... ${R}FAILED${N}" | tee -a "$LOGFILE"
  exit 1
fi

# Reload systemd daemon
systemctl daemon-reload &>> "$LOGFILE"
VALIDATE $? "Systemd daemon reload"

# Enable cart service if not already enabled
if systemctl is-enabled cart &>/dev/null; then
  echo -e "✅ cart service already enabled ... ${Y}SKIPPING${N}" | tee -a "$LOGFILE"
else
  systemctl enable cart &>> "$LOGFILE"
  VALIDATE $? "Enabling cart service"
fi

# Restart cart service (restart is safer on multiple runs)
systemctl restart cart &>> "$LOGFILE"
VALIDATE $? "Restarting cart service"

echo -e "✅ ${G}Cart component setup completed successfully.${N}" | tee -a "$LOGFILE"
