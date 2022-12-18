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

# Initialize borg backup repo.
borg_init() {
    local CMD=(
        "borg"
        "init"
        "--show-rc"
        "--encryption" "keyfile-blake2"
    )

    log 1 1 "Initializing new borg repo $BORG_REPO"

    # Checks
    local ERRORS=""

    # Error if keyfile path already exists
    if [ -f "$BORG_KEY_FILE" ]; then
        ERRORS+="\n- Keyfile $BORG_KEY_FILE already exists."
    fi

    # Error if the target directory is not empty
    local RESULT
    if [ "$REMOTE" = "true" ]; then
        if ! RESULT="$(ssh -i "$REMOTE_SSH_PRIVKEY" -p "$REMOTE_PORT" "$REMOTE_USER@$REMOTE_DOMAIN" "ls -A \"$TARGET_DIRECTORY\"" 2>/dev/null)"; then
            RESULT=""
        fi
    else
        RESULT="$(if [ -d "$TARGET_DIRECTORY" ]; then ls -A "$TARGET_DIRECTORY"; fi)"
    fi

    if [ -n "$RESULT" ]; then
        ERRORS+="\n- The target directory $BORG_REPO is not empty."
    fi

    # If any errors
    if [ -n "$ERRORS" ]; then
        log 1 3 "Unable to initialize Borg repo:$ERRORS"
        exit 1
    fi

    # Initialize Borg repo
    log 0 0 "Running command: ${CMD[*]}"
    if ! "${CMD[@]}" >>"$LOG_FILE" 2>&1; then
        log 1 3 "Error initiating borg repo $BORG_REPO"
        exit 1
    fi

    # Protect the keyfile
    if ! chmod 600 "$BORG_KEY_FILE"; then
        log 1 3 "Unable to set permissions of $BORG_KEY_FILE. Manually set its permissions to 600"
    fi

    # Protect the passphrase file
    if ! chmod 600 "$BACKUP_PASSPHRASE_FILE"; then
        log 1 3 "Unable to set permissions of $BACKUP_PASSPHRASE_FILE. Manually set its permissions to 600"
    fi

    log 1 2 "Successfully initiated borg repo $BORG_REPO.\nMake sure to backup your passphrase and the keyfile"

    cat <<EOF

██╗███╗   ███╗██████╗  ██████╗ ██████╗ ████████╗ █████╗ ███╗   ██╗████████╗██╗
██║████╗ ████║██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝██╔══██╗████╗  ██║╚══██╔══╝██║
██║██╔████╔██║██████╔╝██║   ██║██████╔╝   ██║   ███████║██╔██╗ ██║   ██║   ██║
██║██║╚██╔╝██║██╔═══╝ ██║   ██║██╔══██╗   ██║   ██╔══██║██║╚██╗██║   ██║   ╚═╝
██║██║ ╚═╝ ██║██║     ╚██████╔╝██║  ██║   ██║   ██║  ██║██║ ╚████║   ██║   ██╗
╚═╝╚═╝     ╚═╝╚═╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚═╝

Back up your keyfile and passphrase. Without these two, you will not be able to access your backups.

- Keyfile location: $BORG_KEY_FILE

- Passphrase file location: $BACKUP_PASSPHRASE_FILE

Test that you can access and restore your backups. Ideally, also from another computer.
EOF
}
