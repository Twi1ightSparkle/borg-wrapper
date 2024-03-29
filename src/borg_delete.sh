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

borg_delete() {
    local CMD=(
        "borg"
        "delete"
        "--info"
        "--list"
        "--save-space"
    )

    if [ "$LIVE" != true ]; then
        CMD+=("--dry-run")
    else
        CMD+=("--stats")
    fi


    local MSG
    if [ "$BORG_NAME" ]; then
        CMD+=("::$BORG_NAME")
        MSG="backup $BORG_REPO::$BORG_NAME"
    else
        CMD+=("--glob-archives" "$BACKUP_PREFIX*")
        MSG="backups matching $BORG_REPO::$BACKUP_PREFIX*"

        local ANSWER
        read -r -p "This will delete all your backups. Type \"erase all backups\" in all uppercase to continue: " ANSWER
        if [ ! "$ANSWER" = "ERASE ALL BACKUPS" ]; then
            exit 0
        fi
    fi

    log 1 1 "Deleting $MSG"
    log 0 0 "Running command: ${CMD[*]}"

    if ! "${CMD[@]}" >>"$LOG_FILE" 2>&1; then
        log 1 3 "Failed to delete $MSG"
        exit 1
    fi

    log 1 1 "Successfully deleted $MSG"
}
