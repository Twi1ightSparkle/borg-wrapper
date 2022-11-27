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

borg_prune() {
    log 1 1 "Pruning archives matching $BORG_REPO::$HOSTNAME-*"
    if ! borg prune \
        --info \
        --list \
        --keep-hourly "$BORG_KEEP_HOURLY" \
        --keep-daily "$BORG_KEEP_DAILY" \
        --keep-weekly "$BORG_KEEP_WEEKLY" \
        --keep-monthly "$BORG_KEEP_MONTHLY" \
        --keep-yearly "$BORG_KEEP_YEARLY" \
        --keep-within "$BORG_KEEP_WITHIN" \
        --glob-archive "$BORG_BACKUP_PREFIX*" \
        >> "$BORG_LOG_FILE" 2>&1
    then
        log 1 2 "Failed to create backup $BACKUP_NAME. See the log for more info"
        exit 1
    fi

    log 1 1 "Successfully pruned archives matching $BORG_REPO::$HOSTNAME-*"

}
