#!/bin/bash

ID=$(id -u)

TIMESTAMP=$(date "+%F-%T")  # %F = YYYY-MM-DD, %T = HH:MM:SS
LOGFILE="/tmp/$0-$TIMESTAMP.log"


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


echo "script start executing at $TIMESTAMP" &>> $LOGFILE 

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "❌ ERROR: $2 ... $R FAILED $N"
        exit 1
    else
        echo -e "✅ SUCCESS: $2 ... $G SUCCESS $N"
    fi
}


 if [ $ID -ne 0 ]; then
        echo -e "❌ ERROR: $2 ... $R PLease run the script with root access $N"
        exit 1
    else
        echo -e "✅ SUCCESS: $2 ... $G You are a root user $N"
    fi


curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "Configure YUM Repos from the script provided by vendor" 



curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "Configure YUM Repos for RabbitMQ" 


dnf install rabbitmq-server -y  &>> $LOGFILE
VALIDATE $? "Installing... RabbitMQ" 


systemctl enable rabbitmq-server  &>> $LOGFILE
VALIDATE $? "Enabling ... rabbitmq "


# Start RabbitMQ service if not already running
systemctl is-active --quiet rabbitmq-server
if [ $? -eq 0 ]; then
    echo -e "✅ RabbitMQ is already running ... $Y SKIPPING START $N" | tee -a $LOGFILE
else
    systemctl start rabbitmq-server &>> $LOGFILE
    VALIDATE $? "Started RabbitMQ service"
fi

# Add user roboshop if not exists
rabbitmqctl list_users | grep roboshop &>> $LOGFILE
if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
    VALIDATE $? "Adding RabbitMQ user: roboshop"
else
    echo -e "✅ RabbitMQ user roboshop already exists ... $Y SKIPPING ADD $N" | tee -a $LOGFILE
fi

# Set permissions for roboshop user
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE
VALIDATE $? "Set permissions for RabbitMQ user: roboshop"



