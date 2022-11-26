#!/bin/bash

# This script cannot be run on it's own. From the repo root, run ./borg.sh

# Initialize borg backup repo.
borg_init() {
    log 1 1 "Initalizing new borg repo $BORG_REPO"

    # Checks
    ERRORS=""

    if [ -f "$BORG_KEY_FILE" ]; then
        ERRORS+="\nKeyfile $BORG_KEY_FILE already exists."
    fi

    if [ "$BORG_REMOTE" ]; then
        echo "TODO: Implement remote empty dir check chech"
    else
        if [ -d "$BORG_TARGET_DIRECTORY" ] && [ -n "$(ls --almost-all "$BORG_TARGET_DIRECTORY")" ]; then
            ERRORS+="\nTarget directory $BORG_TARGET_DIRECTORY is not empty."
        fi
    fi

    if [ -n "$ERRORS" ]; then
        log 1 2 "Unable to initialize Borg repo:$ERRORS"
        exit 1
    fi

    # Initialize Borg repo
    if ! borg init \
        --encryption keyfile-blake2 \
        >> "$BORG_LOG_FILE" 2>&1
    then
        log 1 2 "Error initiating borg repo $BORG_REPO"
        exit 1
    fi

    # Protect the keyfile
    if ! chmod 600 "$BORG_KEY_FILE"; then
        log 1 2 "Unable to set permissions of $BORG_KEY_FILE. Manually set its permissions to 600."
    fi

    log 1 1 "Successfully initiated borg repo $BORG_REPO.\nMake sure to backup your passphrase and the key file $BORG_KEY_FILE"
}
