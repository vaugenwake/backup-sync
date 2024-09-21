FROM ubuntu:24.04

RUN apt update -y && \
    apt install -y mysql-client python3 curl unzip less cron

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

#RUN ln -s /usr/bin/python3 /usr/bin/python

WORKDIR /app

#RUN useradd --create-home runner
#USER runner

COPY backup.sh /app/backup.sh
COPY backup-cron /etc/cron.d/backup-cron

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/backup-cron

# Apply cron job
RUN crontab /etc/cron.d/backup-cron

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Run the command on container startup
CMD cron && tail -f /var/log/cron.log


#ENTRYPOINT ["/app/backup.sh"]