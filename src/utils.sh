#!/bin/bash

# This script cannot be run on it's own. From the repo root, run ./borg.sh

# Borg backup runner. Wrapper script for basic borg backup features.
# Copyright (C) 2022  Twilight Sparkle
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Returns the current time stamp in format 2022-11-26T18:32:49.564Z
iso_time_stamp() {
    NANOSECONDS="$(date "+%N")"
    MILLISECONDS="${NANOSECONDS:0:3}"
    DATE="$(date -u "+%Y-%m-%dT%H:%M:%S")"
    Z="Z"
    echo "$DATE.$MILLISECONDS$Z"
}

# Send a message to the webhook. Params:
# 1: Notify. @rooms if true
# 2: Message content
webhook() {
    if [ "$BORG_WEBHOOK_ENABLE" ]; then
        PAYLOAD="{\"notify\":$1,\"text\":\"**$HOSTNAME:** $2\"}"
        {
            echo "$(iso_time_stamp) Sending payload $PAYLOAD to $BORG_WEBHOOK_URL"
            curl \
                --location \
                --silent \
                --request PUT \
                --header 'Content-Type: application/json' \
                --data-raw "$PAYLOAD" \
                "$BORG_WEBHOOK_URL"
            echo ""
        } >>"$BORG_LOG_FILE"
    fi
}

# Test the webhook. Sends two calls, one with and one without @room
test_webhook() {
    if [ "$BORG_WEBHOOK_ENABLE" ]; then
        webhook false "Webhook test from $HOSTNAME with @ room off"
        webhook true "Webhook test from $HOSTNAME with @ room on"
    else
        echo "Webhook disabled in config"
    fi
}

# Log some text to the log file. Params:
# 1: 0 log to file only, 1 also print to console
# 2: 0 do not log to webhook, 1 log to webhook, 2 also @room with webhook
# 3: The text to log
log() {
    PRINT="$1"
    HOOK="$2"
    MESSAGE="$3"
    # Replace all newlines (\n) with a space
    MESSAGE_ONE_LINE=${MESSAGE//\\n/ }

    echo "$(iso_time_stamp) $MESSAGE_ONE_LINE" >>"$BORG_LOG_FILE"

    if [ ! "$AUTOMATED" ] && [ "$PRINT" = 1 ]; then
        echo -e "$MESSAGE"
    fi

    if [ "$HOOK" = 1 ]; then
        webhook false "$MESSAGE_ONE_LINE"
    elif [ "$HOOK" = 2 ]; then
        webhook true "$MESSAGE_ONE_LINE"
    fi
}

# Make sure required env options are set
check_required_env() {
    log 0 0 "Checking if required variables are set"
    MISSING=""

    if [[ ! "$BORG_BACKUP_PASSPHRASE" ]]; then MISSING+="\nBORG_BACKUP_PASSPHRASE "; fi
    if [[ ! "$BORG_TARGET_DIRECTORY" ]]; then MISSING+="\nBORG_TARGET_DIRECTORY "; fi

    if [ "$BORG_REMOTE" ]; then
        if [[ ! "$BORG_REMOTE_DOMAIN" ]]; then MISSING+="\nBORG_REMOTE_DOMAIN "; fi
        if [[ ! "$BORG_REMOTE_USER" ]]; then MISSING+="\nBORG_REMOTE_USER "; fi
        if [[ ! "$BORG_SSH_PRIVKEY" ]]; then MISSING+="\nBORG_SSH_PRIVKEY "; fi
    fi

    if [ "$BORG_WEBHOOK_ENABLE" ]; then
        if [[ ! "$BORG_WEBHOOK_URL" ]]; then MISSING+="\nBORG_WEBHOOK_URL "; fi
    fi

    if [ -n "$MISSING" ]; then
        log 1 0 "The following required options are missing from your borg.env file:$MISSING"
        exit 1
    fi
}

# Make sure required programs are installed
check_required_programs() {
    log 0 0 "Checking if required programs are installed"
    PROGRAMS=(bash borg cat chmod curl date echo hostname ssh)
    MISSING=""
    for PROGRAM in "${PROGRAMS[@]}"; do
        if ! hash "$PROGRAM" &> /dev/null; then
            MISSING+="\n$PROGRAM "
        fi
    done

    if [ -n "$MISSING" ]; then
        log 1 0 "Some required programs missing on this system. Please install:$MISSING"
        exit 1
    fi
}

# Test ssh connection to the target server
test_target_connectivity() {
    if ! ssh -i "$BORG_SSH_PRIVKEY" -p "$BORG_REMOTE_PORT" "$BORG_REMOTE_USER@$BORG_REMOTE_DOMAIN" "exit"; then
        log 1 2 "Unable to ssh to $BORG_REMOTE_USER@$BORG_REMOTE_DOMAIN"
        exit 1
    fi

    if ! ssh -i "$BORG_SSH_PRIVKEY" -p "$BORG_REMOTE_PORT" "$BORG_REMOTE_USER@$BORG_REMOTE_DOMAIN" "borg --version >/dev/null 2>&1"; then
        log 1 2 "borg not available on $BORG_REMOTE_DOMAIN"
        exit 1
    fi
}

# Print help text
print_help() {
    cat <<EOF
$PROGRAM_NAME

Usage: ./borg.sh OPTION [params] [automated]

Options:
    * = not yet implemented
    - *backup                Create new backup
    - *compact               Free up repository space by compacting segments
    - help                   This help text
    - init                   Initialize a new backup repository
    - *list                  List all backups
    - *mount     id path     Mount backup with id at path
    - *prune                 Prunes the repository by deleting all archives not
                             matching any of the specified retention options
    - testhook               Test webhook (if enabled in the config)
    - version                Print version number
    - *unmount               Unmount the mounted backup

Adding option automated disables all log messages to stdout.

Additional documentation in the README.md file or at
https://github.com/twi1ightsparkle/borg

Maintained by Twilight Sparkle
Version $PROGRAM_VERSION
EOF
}
