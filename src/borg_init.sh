#!/bin/bash

# This script cannot be run on it's own. From the repo root, run ./borg.sh

# Initialize borg backup repo.
borg_init() {
    if [ -f "$BORG_KEY_FILE" ]; then
        echo "Error, keyfile already exists. $BORG_KEY_FILE"
        exit 1
    fi

    log 0 "Initalizing new borg repo $BORG_REPO from host $HOSTNAME"

    if ! borg init \
        --encryption keyfile-blake2 \
        >> "$BORG_LOG_FILE" 2>&1
    then
        log 2 "Error initiating borg repo $BORG_REPO from host $HOSTNAME"
        exit 1
    fi

    chmod 600 "$BORG_KEY_FILE"

    echo ""
    msg="Successfully initiated borg repo $BORG_REPO from host $HOSTNAME"
    log 1 "$msg"
    echo "$msg"
    echo "Make sure to backup your password and the key file: $BORG_KEY_FILE"
}
