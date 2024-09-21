#!/usr/bin/env bash

NOTVALID=0

if [ -z "${BACKUP_MYSQL_PASSWORD_FILE}" ]; then
  printf "MySQL password secret file not provided"
  NOTVALID=1
fi

if [ -z "${BACKUP_MYSQL_HOST}" ]; then
  printf "MySQL host not provided"
  NOTVALID=1
fi

if [ -z "${BACKUP_MYSQL_PORT}" ]; then
  printf "MySQL port not provided"
  NOTVALID=1
fi

if [ -z "${AWS_ACCESS_KEY_FILE}" ]; then
  printf "AWS Access Key not provided"
  NOTVALID=1
fi

if [ -z "${AWS_SECRET_KEY_FILE}" ]; then
  printf "AWS Secret Key not provided"
  NOTVALID=1
fi

if [[ $NOTVALID == 1 ]]; then
  exit 1
fi

if [[ ! -d "/tmp/backups" ]]; then
  echo "Temp backup dir does not exist, creating it"
  mkdir /tmp/backups
fi

printf "Reading secrets\n"

MYSQL_PASSWORD=$(cat $BACKUP_MYSQL_PASSWORD_FILE) || 0

if [[ $MYSQL_PASSWORD == 0 ]]; then printf "Could not read secrets file\n"; exit 1; fi

echo "Starting backup process"

TIMESTAMP=$(date +%s)
FILENAME="backup_$TIMESTAMP.sql"
OUTPUT_PATH="/tmp/backups/$FILENAME"

mysqldump \
  -h $BACKUP_MYSQL_HOST \
  -u $BACKUP_MYSQL_USER \
  -p$MYSQL_PASSWORD \
  -P $BACKUP_MYSQL_PORT \
  $BACKUP_MYSQL_DATABASE --no-tablespaces --skip-add-locks > $OUTPUT_PATH

if [ ! -f $OUTPUT_PATH ]; then
  echo "Backup file not created, skipping sync to s3"
  exit 1
fi

echo "Syncing to S3"

export AWS_ACCESS_KEY_ID=$(cat $AWS_ACCESS_KEY_FILE) || 0
export AWS_SECRET_ACCESS_KEY=$(cat $AWS_SECRET_KEY_FILE) || 0

aws s3 cp $OUTPUT_PATH s3://${AWS_S3_BUCKET_NAME}/${S3_BACKUP_SUBDIRECTORY}/${FILENAME}

echo "Backup complete"

echo "Checking for history backups to be removed"

CLEANUP=$(aws s3api list-objects-v2 --bucket ${AWS_S3_BUCKET_NAME} --prefix ${S3_BACKUP_SUBDIRECTORY}/backup_ --query 'Contents[].[Key]' --output text | head -n -4)

TOTAL=$(echo $CLEANUP | sed '/^$/d' | wc -l)

if [[ $TOTAL > 0 ]]; then
  echo "Cleaning up $TOTAL backup(s)"

  for delete in $CLEANUP;
  do
    echo "Deleting: $delete"
    aws s3 rm s3://${AWS_S3_BUCKET_NAME}/${delete}
  done

  else
    echo "No history backups to remove"
fi

echo "Cleaning up local copy"
rm -rf $OUTPUT_PATH