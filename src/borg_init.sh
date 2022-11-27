#!/bin/bash

# This script cannot be run on it's own. From the repo root, run ./borg.sh

# Borg backup runner. An (almost) no-dependency wrapper script for basic Borg backup features.
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

# Initialize borg backup repo.
borg_init() {
    CMD=(
        "borg"
        "init"
        "--encryption" "keyfile-blake2"
    )

    log 1 1 "Initializing new borg repo $BORG_REPO"

    # Checks
    ERRORS=""

    if [ -f "$BORG_KEY_FILE" ]; then
        ERRORS+="\nKeyfile $BORG_KEY_FILE already exists."
    fi

    if [ "$BORG_REMOTE" ]; then
        RESULT="$(ssh -i "$BORG_SSH_PRIVKEY" -p "$BORG_REMOTE_PORT" "$BORG_REMOTE_USER@$BORG_REMOTE_DOMAIN" "if [ -d \"$BORG_TARGET_DIRECTORY\" ]; then ls --almost-all \"$BORG_TARGET_DIRECTORY\"; fi")"
        if [ -n "$RESULT" ]; then
            ERRORS+="\The target directory $BORG_REMOTE_USER@$BORG_REMOTE_DOMAIN:$BORG_TARGET_DIRECTORY is not empty."
        fi
    else
        if [ -d "$BORG_TARGET_DIRECTORY" ] && [ -n "$(ls --almost-all "$BORG_TARGET_DIRECTORY")" ]; then
            ERRORS+="\The target directory $BORG_TARGET_DIRECTORY is not empty."
        fi
    fi

    if [ -n "$ERRORS" ]; then
        log 1 2 "Unable to initialize Borg repo:$ERRORS"
        exit 1
    fi

    log 0 0 "Running command: ${CMD[*]}"

    # Initialize Borg repo
    if ! "${CMD[@]}" >>"$BORG_LOG_FILE" 2>&1; then
        log 1 2 "Error initiating borg repo $BORG_REPO"
        exit 1
    fi

    # Protect the keyfile
    if ! chmod 600 "$BORG_KEY_FILE"; then
        log 1 2 "Unable to set permissions of $BORG_KEY_FILE. Manually set its permissions to 600"
    fi

    log 1 1 "Successfully initiated borg repo $BORG_REPO.\nMake sure to backup your passphrase and the key file $BORG_KEY_FILE"
}
