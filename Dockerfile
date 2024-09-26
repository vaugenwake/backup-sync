FROM ubuntu:24.04

RUN apt update -y && \
    apt install -y mysql-client python3 curl unzip less cron

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

WORKDIR /app

COPY backup.sh /app/backup.sh
COPY backup-cron /etc/cron.d/backup-cron

RUN chmod 0644 /etc/cron.d/backup-cron

RUN crontab /etc/cron.d/backup-cron

RUN touch /var/log/cron.log

CMD cron && tail -f /var/log/cron.log