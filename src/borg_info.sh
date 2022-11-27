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

borg_info() {
    CMD=("borg" "info")
    MSG="repo $BORG_REPO"

    if [ "$NAME" ]; then
        CMD+=("::$NAME")
        MSG="backup $BORG_REPO::$NAME"
    fi

    log 1 0 "Detailed info about $MSG"
    log 0 0 "Running command: ${CMD[*]}"

    if ! "${CMD[@]}"; then
        log 1 0 "Failed to get info about $BORG_REPO"
        exit 1
    fi
}