#!/bin/bash

LOGFILE="/tmp/dispatch-setup-$(date +%F-%T).log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo -e "${Y}Starting Dispatch setup at $(date)${N}" | tee -a "$LOGFILE"

VALIDATE() {
  if [ $1 -ne 0 ]; then
    echo -e "❌ ERROR: $2 ... $R FAILED $N" | tee -a "$LOGFILE"
    exit 1
  else
    echo -e "✅ SUCCESS: $2 ... $G SUCCESS $N" | tee -a "$LOGFILE"
  fi
}

# Run as root check
if [ "$(id -u)" -ne 0 ]; then
  echo -e "❌ Please run as root" | tee -a "$LOGFILE"
  exit 1
fi

# Check curl and unzip installed
for cmd in curl unzip; do
  if ! command -v $cmd &>/dev/null; then
    dnf install -y $cmd &>> "$LOGFILE"
    VALIDATE $? "Installing $cmd"
  else
    echo -e "✅ $cmd already installed ... $Y SKIPPING $N" | tee -a "$LOGFILE"
  fi
done

# Install golang if not installed
if ! command -v go &>/dev/null; then
  dnf install golang -y &>> "$LOGFILE"
  VALIDATE $? "Installing golang"
else
  echo -e "✅ Golang already installed ... $Y SKIPPING $N" | tee -a "$LOGFILE"
fi

# Add roboshop user if not exists
if ! id roboshop &>/dev/null; then
  useradd roboshop &>> "$LOGFILE"
  VALIDATE $? "Adding user roboshop"
else
  echo -e "✅ User roboshop exists ... $Y SKIPPING $N" | tee -a "$LOGFILE"
fi

# Create /app directory if not exists, and set ownership to roboshop
if [ ! -d /app ]; then
  mkdir /app
  VALIDATE $? "Creating /app directory"
else
  echo -e "✅ /app directory exists ... $Y SKIPPING $N" | tee -a "$LOGFILE"
fi
chown roboshop:roboshop /app

# Download dispatch.zip (overwrite every time for fresh deploy)
curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>> "$LOGFILE"
VALIDATE $? "Downloading dispatch.zip"

# Clean up old app content
rm -rf /app/*

# Unzip dispatch.zip into /app
unzip /tmp/dispatch.zip -d /app &>> "$LOGFILE"
VALIDATE $? "Unzipping dispatch.zip"

# Switch to roboshop user to build app
sudo -u roboshop bash << EOF
cd /app

# Initialize module if go.mod missing
if [ ! -f go.mod ]; then
  go mod init dispatch &>> "$LOGFILE"
fi

go mod tidy &>> "$LOGFILE"
go build &>> "$LOGFILE"
EOF

VALIDATE $? "Building Go application"

# Create systemd service file for dispatch app
SERVICE_FILE="/etc/systemd/system/dispatch.service"
cat > "$SERVICE_FILE" << EOF
[Unit]
Description=Dispatch Service
After=network.target

[Service]
User=roboshop
WorkingDirectory=/app
Environment=AMQP_HOST=RABBITMQ-IP
Environment=AMQP_USER=roboshop
Environment=AMQP_PASS=roboshop123
ExecStart=/app/dispatch
Restart=always
SyslogIdentifier=dispatch

[Install]
WantedBy=multi-user.target
EOF

VALIDATE $? "Creating systemd service file"

# Reload systemd and enable/start service
systemctl daemon-reload &>> "$LOGFILE"
VALIDATE $? "Reloading systemd daemon"

systemctl enable dispatch &>> "$LOGFILE"
VALIDATE $? "Enabling dispatch service"

systemctl restart dispatch &>> "$LOGFILE"
VALIDATE $? "Starting dispatch service"

echo -e "${G}Dispatch setup completed successfully!${N}" | tee -a "$LOGFILE"
