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

# Params:
# 1: true to ignore --live requirement
borg_prune() {
    CMD=(
        "borg"
        "prune"
        "--info"
        "--list"
        "--show-rc"
        "--keep-hourly" "$KEEP_HOURLY"
        "--keep-daily" "$KEEP_DAILY"
        "--keep-weekly" "$KEEP_WEEKLY"
        "--keep-monthly" "$KEEP_MONTHLY"
        "--keep-yearly" "$KEEP_YEARLY"
        "--keep-within" "$KEEP_WITHIN"
        "--glob-archive" "$BACKUP_PREFIX*"
    )

    if [ "$LIVE" != true ]; then
        CMD+=("--dry-run")
    fi

    log 1 1 "Pruning archives matching $BORG_REPO::$BACKUP_PREFIX*"
    log 0 0 "Running command: ${CMD[*]}"

    if ! "${CMD[@]}" >>"$LOG_FILE" 2>&1; then
        log 1 2 "Failed to prune archives matching $BORG_REPO::$BACKUP_PREFIX*. See the log for more info"
        exit 1
    fi

    log 1 1 "Successfully pruned archives matching $BORG_REPO::$BACKUP_PREFIX*"
}
