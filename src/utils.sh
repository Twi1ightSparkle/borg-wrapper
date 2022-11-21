#!/bin/bash

# This scrfipt cannot be run on it's own. From the repo root, run ./borg.sh

# Returns the current time stamp in format 2022-07-23T14-56-03Z
zulu_time() {
    date -u "+%Y-%m-%dT%H-%M-%SZ"
}

# Send a message to the webhook. Params:
# 1: Notify. @rooms if true
# 2: Message content
webhook() {
    PAYLOAD="{\"notify\":$1,\"text\":\"$2\"}"
    {
        echo "Sending payload $PAYLOAD to $BORG_WEBHOOK_URL"
        curl \
            --location \
            --silent \
            --request PUT \
            --header 'Content-Type: application/json' \
            --data-raw "$PAYLOAD" \
            "$BORG_WEBHOOK_URL"
        echo ""
    } >>"$BORG_LOG_FILE"
}

# Log some text to the log file. Params:
# 1: 0 just log to file only, 1 also log to webhook, 2 also @room with webhook
# 2: The text to log
log() {
    echo "$(zulu_time) $2" >>"$BORG_LOG_FILE"

    if [ "$1" = 1 ]; then
        webhook false "$2"
    elif [ "$1" = 2 ]; then
        webhook true "$2"
    fi
}

# Make sure borg is installed
if ! command borg >/dev/null 2>&1; then
    log 2 "Error: borg backup does not appear to be installed on $HOSTNAME"
    exit 1
fi

# Set borg repo
if [[ "$BORG_REMOTE" ]]; then
    export BORG_REPO="ssh://$BORG_REMOTE_USER@$BORG_REMOTE_DOMAIN:$BORG_TARGET_DIRECTORY"
    export BORG_RSH="ssh -i $BORG_SSH_PRIVKEY"
else
    export BORG_REPO="$BORG_TARGET_DIRECTORY"
fi

# Check to see if we can backup
# Stolen from https://github.com/rtrouton/CasperCheck/blob/master/script/caspercheck.sh
# Thanks, Rich.
check_for_network() {
    # Determine if the network is up by looking for any non-loopback network interfaces.
    local test

    if [[ -z "${NETWORKUP:=}" ]]; then
        test=$(ifconfig -a inet 2>/dev/null | sed -n -e '/127.0.0.1/d' -e '/0.0.0.0/d' -e '/inet/p' | wc -l)

        if [[ "${test}" -gt 0 ]]; then
            NETWORKUP="-YES-"
        else
            NETWORKUP="-NO-"
        fi

    fi
}

check_site_network() {
    site_network="False"
    ssh_check=$(ssh "${BORG_REPO}" "hostname")

    if [[ "${ssh_check}" == "${BORG_REPO}" ]]; then
        site_network="True"
    else
        site_network="False"
    fi
}

# Print help text
print_help() {
    cat <<EOF
Borg backup runner

Usage: ./borg.sh OPTION [params]

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
    - *unmount               Unmount the mounted backup

Additional documentation in the README.md file or at
https://github.com/twi1ightsparkle/borg

Maintained by Twilight Sparkle
Version 1.0.0
EOF
}
