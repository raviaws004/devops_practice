#!/bin/bash

# Dispatch Setup Script
LOGFILE="/tmp/dispatch-setup-$(date +%F-%H-%M-%S).log"
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

# Install GoLang if not installed
if ! command -v go &>/dev/null; then
  dnf install golang -y &>> "$LOGFILE"
  VALIDATE $? "Installing GoLang"
else
  echo -e "✅ GoLang already installed ... $Y SKIPPING $N" | tee -a "$LOGFILE"
fi

# Add application user
if ! id roboshop &>/dev/null; then
  useradd roboshop &>> "$LOGFILE"
  VALIDATE $? "Adding user roboshop"
else
  echo -e "✅ User roboshop already exists ... $Y SKIPPING $N" | tee -a "$LOGFILE"
fi

# Create /app directory
if [ ! -d /app ]; then
  mkdir /app
  VALIDATE $? "Creating /app directory"
else
  echo -e "✅ /app directory exists ... $Y SKIPPING $N" | tee -a "$LOGFILE"
fi
chown -R roboshop:roboshop /app

# Download and extract dispatch app
curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>> "$LOGFILE"
VALIDATE $? "Downloading dispatch.zip"

rm -rf /app/*
unzip /tmp/dispatch.zip -d /app &>> "$LOGFILE"
VALIDATE $? "Unzipping dispatch.zip"

# Build the Go app as roboshop user
sudo -u roboshop bash << 'EOF'
cd /app
if [ ! -f go.mod ]; then
  go mod init dispatch
fi
go mod tidy
go build
EOF
VALIDATE $? "Building Go Application"

# Create systemd service file
SERVICE_FILE="/etc/systemd/system/dispatch.service"
cat > "$SERVICE_FILE" << EOF
[Unit]
Description=Dispatch Service
After=network.target

[Service]
User=roboshop
WorkingDirectory=/app
Environment=AMQP_HOST=172.31.81.24
Environment=AMQP_USER=roboshop
Environment=AMQP_PASS=roboshop123
ExecStart=/app/dispatch
Restart=always
SyslogIdentifier=dispatch

[Install]
WantedBy=multi-user.target
EOF
VALIDATE $? "Creating systemd service file"

# Start and enable the service
systemctl daemon-reload &>> "$LOGFILE"
VALIDATE $? "Systemd daemon reload"

systemctl enable dispatch &>> "$LOGFILE"
VALIDATE $? "Enabling dispatch service"

systemctl restart dispatch &>> "$LOGFILE"
VALIDATE $? "Starting dispatch service"

echo -e "${G}✅ Dispatch setup completed successfully!${N}" | tee -a "$LOGFILE"
