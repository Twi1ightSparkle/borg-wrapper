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

borg_check() {
    local CMD=(
        "borg"
        "check"
        "--show-rc"
    )

    local MSG
    MSG="repo $BORG_REPO"

    if [ "$BORG_NAME" ]; then
        CMD+=("::$BORG_NAME")
        MSG="backup $BORG_REPO::$BORG_NAME"
    fi

    log 1 1 "Verifying the consistency of $MSG"
    log 0 0 "Running command: ${CMD[*]}"

    if ! "${CMD[@]}" >>"$LOG_FILE" 2>&1; then
        log 1 3 "Failed to verify the consistency of $MSG"
        exit 1
    fi

    log 1 1 "Successfully verified the consistency of $MSG"
}
