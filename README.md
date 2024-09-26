# Backup Sync

Backup sync is a simple and lightweight container to facilitate daily mysql backups for apps running as a stack in docker swarm.

### Requirements:
* MySQL 8
* Docker swarm
* Docker secrets (Used to pass around passwords and access tokens)
* S3 compatiable storage destination

## Usage
To use backup sync you simply need to have access to an S3 bucket and then add the container to your applications docker swarm stack.

**Example:**
```YAML
version: 3.9

networks:
    mystack:

services:
    mysql:
    image: mysql:8
    deploy:
      mode: replicated
      replicas: 1
    environment:
      MYSQL_DATABASE: mydb
      MYSQL_USER: mydb
      MYSQL_PASSWORD_FILE: /run/secrets/db_password
      MYSQL_ALLOW_EMPTY_PASSWORD: "false"
      MYSQL_RANDOM_ROOT_PASSWORD: "yes"
    secrets:
      - db_password
    networks:
      - mystack

  backups:
    image: vaugenwake/backup-sync:latest
    environment:
      - BACKUP_MYSQL_HOST=mysql
      - BACKUP_MYSQL_PORT=3306
      - BACKUP_MYSQL_PASSWORD_FILE=/run/secrets/db_password
      - BACKUP_MYSQL_USER=mydb
      - BACKUP_MYSQL_DATABASE=mydb # Name of database to backup
      - AWS_DEFAULT_REGION=us-east-1
      - AWS_S3_BUCKET_NAME=tradigital-db-backups # Name of bucket to upload to
      - AWS_ACCESS_KEY_FILE=/run/secrets/backup_s3_access_token
      - AWS_SECRET_KEY_FILE=/run/secrets/backup_s3_secret
      - S3_BACKUP_SUBDIRECTORY=mydb-backups # Subdirectory for app backups within bucket
    deploy:
      restart_policy:
        condition: on-failure
        max_attempts: 1
      placement:
        constraints:
          - node.role == manager
    secrets:
      - db_password
      - backup_s3_access_token
      - backup_s3_secret
    networks:
      - mystack

secrets:
    db_password:
        external: true
    backup_s3_access_token:
        external: true
    backup_s3_secret:
        external: true
```

### Note:
Your backup container and mysql database container must both be running in the same docker network