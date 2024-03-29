#!/bin/bash

# This script cannot be run on it's own. From the repo root, run ./borg-wrapper.sh

# Borg wrapper. An (almost) no-dependency wrapper script for basic Borg backup features.
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
    local DATE
    DATE="$(date -u "+%Y-%m-%dT%H:%M:%S")"
    local NANOSECONDS
    NANOSECONDS="$(date "+%N")"
    local Z="Z"
    if [ "$NANOSECONDS" = "N" ]; then
        echo "$DATE$Z"
    else
        local MILLISECONDS="${NANOSECONDS:0:3}"
        echo "$DATE.$MILLISECONDS$Z"
    fi
}

# Send a message to the webhook. Params:
# 1: Notify. @rooms if true
# 2: Message content
webhook() {
    if [ "$WEBHOOK_ENABLED" = "true" ]; then
        local PAYLOAD="{\"notify\":$1,\"text\":\"**$HOSTNAME:** $2\"}"
        {
            echo "$(iso_time_stamp) Sending payload $PAYLOAD to $WEBHOOK_URL"
            curl \
                --location \
                --silent \
                --request PUT \
                --header 'Content-Type: application/json' \
                --data-raw "$PAYLOAD" \
                "$WEBHOOK_URL"
            echo ""
        } >>"$LOG_FILE"
    fi
}

# Test the webhook. Sends two calls, one with and one without @room
test_webhook() {
    if [ "$WEBHOOK_ENABLED" = "true" ]; then
        webhook false "Webhook test from $HOSTNAME with @ room off"
        webhook true "Webhook test from $HOSTNAME with @ room on"
    else
        echo "Webhook disabled in the config"
    fi
}

# Log some text to the log file. Params:
# 1: 0 log to file only, 1 also print to console
# 2: 0 do not log to webhook, 1 log to webhook when WEBHOOK_VERBOSE=true,
#    2 always log to webhook, 3 also @room with webhook
# 3: The text to log
log() {
    local PRINT="$1"
    local HOOK="$2"
    local MESSAGE="$3"
    # Replace all newlines (\n) with a space
    local MESSAGE_ONE_LINE=${MESSAGE//\\n/ }

    echo "$(iso_time_stamp) $MESSAGE_ONE_LINE" >>"$LOG_FILE"

    if [[ ! "$AUTOMATED" && "$PRINT" = 1 ]]; then
        echo -e "$MESSAGE"
    fi

    if [[ ("$HOOK" = 1 && "$WEBHOOK_VERBOSE" = "true") || "$HOOK" = 2 ]]; then
        webhook false "$MESSAGE_ONE_LINE"
    elif [ "$HOOK" = 3 ]; then
        webhook true "$MESSAGE_ONE_LINE"
    fi
}

# Make sure required env options are set
check_required_env() {
    log 0 0 "Checking if required variables are set"
    local MISSING=""

    if [ ! "$TARGET_DIRECTORY" ]; then MISSING+="\nTARGET_DIRECTORY "; fi

    if [ "$REMOTE" = "true" ]; then
        if [ ! "$REMOTE_DOMAIN" ]; then MISSING+="\nREMOTE_DOMAIN "; fi
        if [ ! "$REMOTE_USER" ]; then MISSING+="\nREMOTE_USER "; fi
        if [ ! "$REMOTE_SSH_PRIVKEY" ]; then MISSING+="\nREMOTE_SSH_PRIVKEY "; fi
    fi

    if [ "$WEBHOOK_ENABLED" = "true" ]; then
        if [ ! "$WEBHOOK_URL" ]; then MISSING+="\nWEBHOOK_URL "; fi
    fi

    if [ -n "$MISSING" ]; then
        log 1 3 "The following required options are missing from your borg.env file:$MISSING"
        exit 1
    fi
}

# Make sure required programs are installed
check_required_programs() {
    local PROGRAMS=(bash borg cat cd chmod date dirname echo hostname ls read xargs)

    if [ "$REMOTE" = "true" ]; then PROGRAMS+=(ssh); fi
    if [ "$WEBHOOK_ENABLED" = "true" ]; then PROGRAMS+=(curl); fi

    log 0 0 "Checking if required programs are installed"
    local MISSING=""
    for PROGRAM in "${PROGRAMS[@]}"; do
        if ! hash "$PROGRAM" &>/dev/null; then
            MISSING+="\n$PROGRAM "
        fi
    done

    if [ -n "$MISSING" ]; then
        log 1 3 "Some required programs are missing on this system. Please install:$MISSING"
        exit 1
    fi
}

dry_run_notice() {
    if [ "$LIVE" != true ]; then
        log 1 0 "Running in dry-run mode. See the log file for details"
    fi
}

name_required() {
    if [ -z "$BORG_NAME" ]; then
        log 1 0 "--name option required for this command"
        exit 1
    fi
}

path_required() {
    if [ -z "$MOUNT_PATH" ]; then
        log 1 0 "--path option required for this command"
        exit 1
    fi
}

# Test ssh connection to the target server
test_target_connectivity() {
    if ! ssh -i "$REMOTE_SSH_PRIVKEY" -p "$REMOTE_PORT" "$REMOTE_USER@$REMOTE_DOMAIN" "exit"; then
        log 1 3 "Unable to ssh to $REMOTE_USER@$REMOTE_DOMAIN"
        exit 1
    fi

    if ! ssh -i "$REMOTE_SSH_PRIVKEY" -p "$REMOTE_PORT" "$REMOTE_USER@$REMOTE_DOMAIN" "borg --version" &>/dev/null; then
        log 1 3 "borg not available on $REMOTE_DOMAIN"
        exit 1
    fi
}
