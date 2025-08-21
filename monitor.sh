#!/bin/bash


THRESHOLD=80
LOG_FILE="/var/log/resource_usage.log"

ALERT_METHOD="email"

# Email config
TO_EMAIL="nishanc1711@gmail.com"
FROM_EMAIL="nishanc604@gmail.com"
SUBJECT="Resource Usage Alert"




# Function to send email alert
send_email_alert() {
    BODY=$1
    echo -e "Subject: $SUBJECT\n\n$BODY" | msmtp -a default "$TO_EMAIL"
}


# Collect metrics
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
MEM=$(free | awk '/Mem/ {printf("%.0f"), $3/$2 * 100.0}')
DISK=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

# Log metrics
echo "$(date '+%Y-%m-%d %H:%M:%S') - CPU=${CPU}% MEM=${MEM}% DISK=${DISK}%" >> $LOG_FILE

# Check threshold
ALERT_MSG=""
if [ "${CPU%.*}" -gt "$THRESHOLD" ]; then
    ALERT_MSG+="⚠️ High CPU usage: ${CPU}%\n"
fi
if [ "$MEM" -gt "$THRESHOLD" ]; then
    ALERT_MSG+="⚠️ High Memory usage: ${MEM}%\n"
fi
if [ "$DISK" -gt "$THRESHOLD" ]; then
    ALERT_MSG+="⚠️ High Disk usage: ${DISK}%\n"
fi

# Send alert if needed
if [ -n "$ALERT_MSG" ]; then
    if [ "$ALERT_METHOD" = "email" ]; then
        send_email_alert "$ALERT_MSG"
    elif [ "$ALERT_METHOD" = "slack" ]; then
        send_slack_alert "$ALERT_MSG"
    fi
fi
