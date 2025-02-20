#/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

SOURCE_DIR=$1
DEST_DIR=$2
DAYS=${3:-14}
LOGS_FOLDER="/var/log/shellscript-logs"
LOG_FILE=$(echo $0 | awk -F "/" '{print $NF}' | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
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

USAGE(){
    echo -e "$R USAGE: $N sh delete-mysql.sh <SOURCE-DIR> <DESTINATION-DIR> <DAYS(Optional)>"
    exit 1
}

if [ $# -lt 2 ]
then
    USAGE
fi

if [ -d SOURCE_DIR ]
then
    echo -e "$R Source folder doesn't exist. please validate"
    exit 1
fi

if [ -d DEST_DIR ]
then
    echo -e "$R Destination folder doesn't exist. please validate"
    exit 1
fi

echo "script started executing at:$TIMESTAMP" &>>$LOG_FILE_NAME

FILES=$(find $SOURCE_DIR -name "*.log" -mtime +$DAYS)

if [[ -n $FILES ]]
then
    echo "Files are: $FILES"
    ZIP_FILE="$DEST_DIR/source-$TIMESTAMP.zip"
    find $SOURCE_DIR -name "*.log" -mtime +$DAYS|zip -@ "$ZIP_FILE"
    if [ -f "$ZIP_FILE" ]
    then
        echo -e "Successfully created zip file for files older than $DAYS"
        while read -r filepath
        do
            echo "Deleting file: $filepath" &>>$LOG_FILE_NAME
            rm -rf $filepath
        done <<< $FILES
    else
        echo -e "$R Error: $N failed to create ZIP file"
    fi
else
    echo "No files older than $DAYS"
    echo "ZIP can't be performed"
    exit 1
fi