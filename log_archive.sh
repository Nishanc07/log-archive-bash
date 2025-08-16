#!/bin/bash

# Directories and files
LOG_DIR="/opt/app/logs"
ARCHIVE_DIR="/var/log-archive"
SCRIPT_LOG="/var/log/log-archive-script.log"
LOCK_FILE="/tmp/log-archiver.lock"

# Trap to ensure lock file is removed on exit even if script crashes
trap "rm -f '$LOCK_FILE'" EXIT

# Check if another instance is running
if [ -f "$LOCK_FILE" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Script already running. Exiting." >> "$SCRIPT_LOG"
    exit 1
fi

# Create lock file... echo $$.... you know “this specific process made the lock”
echo $$ > "$LOCK_FILE"

# Log start time
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting log archiving" >> "$SCRIPT_LOG"

# Create archive directory if missing
mkdir -p /var/log-archive

# Create today's archive
TODAY=$(date '+%Y-%m-%d')
ARCHIVE_FILE="$ARCHIVE_DIR/app-logs-$TODAY.tar.gz"

if [ -d "$LOG_DIR" ]; then
    if tar -czf "$ARCHIVE_FILE" -C "$LOG_DIR" . 2>> "$SCRIPT_LOG"; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Created archive: $ARCHIVE_FILE" >> "$SCRIPT_LOG"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Failed to create archive" >> "$SCRIPT_LOG"
        exit 1
    fi
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Log directory $LOG_DIR not found" >> "$SCRIPT_LOG"
    exit 1
fi

# Clean up old archives (keep last 10)
cd "$ARCHIVE_DIR" || exit 1
ARCHIVES=(app-logs-*.tar.gz)
if [ ${#ARCHIVES[@]} -gt 10 ]; then
    ls -t app-logs-*.tar.gz | tail -n +11 | xargs -r rm -f
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Removed old archives, keeping 10 newest" >> "$SCRIPT_LOG"
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Archiving completed successfully" >> "$SCRIPT_LOG"

