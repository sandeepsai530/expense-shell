#/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shellscript-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE(){
    if [[ $1 -ne 0 ]]
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

CHECK_ROOT(){
    if [[ USERID -ne 0 ]]
    then
        echo -e "$R ERROR: You must have a sudo access to execute this script"
        exit 1
    fi
}

echo "script started executing at:$TIMESTAMP" &>>$LOG_FILE_NAME

VALIDATE
CHECK_ROOT
