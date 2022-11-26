#!/bin/bash

# This script cannot be run on it's own. From the repo root, run ./borg.sh

# Initialize borg backup repo.
borg_init() {
    log 0 "Initalizing new borg repo $BORG_REPO from host $HOSTNAME"

    if [ -f "$BORG_KEY_FILE" ]; then
        msg="Error, keyfile already exists. $BORG_KEY_FILE"
        log 2 "$msg"
        echo "$msg"
        exit 1
    fi

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
