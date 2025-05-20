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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copied MOngoDB"

dnf install mongodb-org -y &>> $LOGFILE
VALIDATE $? "Installing ... MongoDB"

systemctl enable mongod
VALIDATE $? "Enabling ... MongoDB"

systemctl start mongod
VALIDATE $? "Starting ... MongoDB"

# (SED - Sreamline Editor) which changes the bind port address from 127.0.0.1 to 0.0.0.0 in /etc/mongod.conf
# SED is a temporary editor
# sed -e : temporary change     syntax:  sed -e <word_to_search>/<word_to_chnages> <filename>
#                               example: sed -e 's/sbin/SBIN/' - changes made in 1st possible lines  
#                                        sed -e 's/sbin/SBIN/g' - changes made in all possible lines
#  --> delete 1st line in the log --     sed -e '1d' <filename>
#  --> delete 2nd line in the log --     sed -e '2d' <filename>
#  --> delete string line in the log --     sed -e '/<string>/d' <filename>


# sed -i : permenenet change    syntax: sed -i <word_to_search>/<word_to_chnages> <filename>

# Update bind IP in mongod.conf
#sed -i '127.0.0.1/0.0.0.0 /g' /etc/mongod.conf &>> $LOGFILE   --> invalid syntax 
sed -i 's/127\.0\.0\.1/0.0.0.0/' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "Updating bind IP in mongod.conf"


systemctl restart mongod
VALIDATE $? "Restarting ... MongoDB"


