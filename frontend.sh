#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1 )
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then 
        echo -e "$2 ... $R NOT A ROOT USER $N"
        exit 1
    else    
        echo -e "$2 --- $G ROOT USER $N"
    fi
}

mkdir -p $LOGS_FOLDER
echo "Script started executing at: $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT

dnf install nginx -y 
VALIDATE $? "installing nginx server"

systemctl enable nginx
VALIDATE $? "enabling nginx server"

systemctl start nginx
VALIDATE $? "starting nginx server"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "removing existing version code"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE $? "Downloading latest code"

cd /usr/share/nginx/html
VALIDATE $? "moving to HTML directory"

unzip /tmp/frontend.zip
VALIDATE $? "unzip frontend code"

systemctl restart nginx
VALIDATE $? "restarting nginx"