#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date "+%F-%T")  # %F = YYYY-MM-DD, %T = HH:MM:SS
SCRIPT_NAME=$(basename "$0")
LOGFILE="/tmp/${SCRIPT_NAME}-${TIMESTAMP}.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

# Configure Erlang repo only if not already configured
if ! yum repolist all | grep -q 'packagecloud_io_erlang'; then
    curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> "$LOGFILE"
    VALIDATE $? "Configure YUM Repos for Erlang"
else
    echo -e "✅ Erlang repo already configured ... $Y SKIPPING $N" &>> "$LOGFILE"
fi

# Configure RabbitMQ repo only if not already configured
if ! yum repolist all | grep -q 'packagecloud_io_rabbitmq_rabbitmq-server'; then
    curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> "$LOGFILE"
    VALIDATE $? "Configure YUM Repos for RabbitMQ"
else
    echo -e "✅ RabbitMQ repo already configured ... $Y SKIPPING $N" &>> "$LOGFILE"
fi

# Install rabbitmq-server only if not installed
if ! rpm -q rabbitmq-server &>/dev/null; then
    dnf install -y rabbitmq-server &>> "$LOGFILE"
    VALIDATE $? "Installing RabbitMQ"
else
    echo -e "✅ RabbitMQ already installed ... $Y SKIPPING $N" &>> "$LOGFILE"
fi

# Enable rabbitmq-server service only if not enabled
if ! systemctl is-enabled rabbitmq-server &>/dev/null; then
    systemctl enable rabbitmq-server &>> "$LOGFILE"
    VALIDATE $? "Enabling RabbitMQ service"
else
    echo -e "✅ RabbitMQ service already enabled ... $Y SKIPPING $N" &>> "$LOGFILE"
fi

# Start rabbitmq-server service if not active
if systemctl is-active --quiet rabbitmq-server; then
    echo -e "✅ RabbitMQ service already running ... $Y SKIPPING START $N" &>> "$LOGFILE"
else
    systemctl start rabbitmq-server &>> "$LOGFILE"
    VALIDATE $? "Starting RabbitMQ service"
fi

# Add user roboshop only if it does not exist
if ! rabbitmqctl list_users | grep -qw roboshop; then
    rabbitmqctl add_user roboshop roboshop123 &>> "$LOGFILE"
    VALIDATE $? "Adding RabbitMQ user: roboshop"
else
    echo -e "✅ RabbitMQ user roboshop already exists ... $Y SKIPPING ADD $N" &>> "$LOGFILE"
fi

# Set permissions only if they are not already set correctly
PERM_CHECK=$(rabbitmqctl list_user_permissions roboshop | grep -w '/')
if [[ "$PERM_CHECK" != *".* .* .*"* ]]; then
    rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> "$LOGFILE"
    VALIDATE $? "Setting permissions for RabbitMQ user: roboshop"
else
    echo -e "✅ Permissions for roboshop user are already set ... $Y SKIPPING PERMISSIONS $N" &>> "$LOGFILE"
fi
