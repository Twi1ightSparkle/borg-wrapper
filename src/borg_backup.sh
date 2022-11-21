#!/bin/bash

# This script cannot be run on it's own. From the repo root, run ./borg.sh

# Create a backup
borg_create() {
    BACKUP_NAME="$HOSTNAME"-"$TIME_STAMP"
    log 1 "Creating backup of $HOSTNAME to $BORG_REPO::$BACKUP_NAME"
    if ! borg create \
        --one-file-system \
        --warning \
        --filter AME \
        --stats \
        --show-rc \
        --compression lz4 \
        --exclude-caches \
        --exclude-from "$SCRIPT_DIR/config/exclude.txt" \
        ::"$BACKUP_NAME" \
        /home/twilight/temp \
        >> "$BORG_LOG_FILE" 2>&1
        # --patterns-from "$SCRIPT_DIR/config/include.txt" \
    then
        log 2 "Failed to create backup $BACKUP_NAME. See the log for more info"
        exit 1
    fi

    log 1 "Successfully backed up $HOSTNAME to $BORG_REPO::$BACKUP_NAME"
}

borg_backup() {
    if [[ "$BORG_REMOTE" ]]; then
        test_target_connectivity
    fi
    borg_create
}
