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

# Create a backup
borg_create() {
    BACKUP_NAME="$BACKUP_PREFIX$TIME_STAMP"
    CMD=(
        "borg"
        "create"
        "--info"
        "--list"
        "--one-file-system"
        "--warning"
        "--filter" "AME"
        "--show-rc"
        "--compression" "lz4"
        "--exclude-caches"
        "--exclude-from" "$EXCLUDE_PATH"
    )

    if [ "$LIVE" = false ]; then
        CMD+=("--dry-run")
    else
        CMD+=("--stats")
    fi

    CMD+=("::$BACKUP_NAME")

    # Read include file
    while read -r LINE; do
        # Trim whitespace
        LINE="$(echo "$LINE" | xargs)"

        # Exclude comments and empty lines
        if [ "$LINE" ] && [[ "$LINE" != "#"* ]]; then
            CMD+=("$LINE")
        fi
    done <"$INCLUDE_PATH"

    log 1 1 "Creating backup to $BORG_REPO::$BACKUP_NAME"
    log 0 0 "Running command: ${CMD[*]}"

    if ! "${CMD[@]}" >>"$LOG_FILE" 2>&1; then
        log 1 2 "Failed to create backup $BACKUP_NAME. See the log for more info"
        exit 1
    fi

    log 1 1 "Successfully backed up to $BORG_REPO::$BACKUP_NAME"
}

borg_backup() {
    borg_create
    if [ "$PRUNE_ON_BACKUP" = "true" ]; then
        borg_prune
    fi
    if [ "$COMPACT_ON_BACKUP" = "true" ]; then
        borg_compact
    fi
}
