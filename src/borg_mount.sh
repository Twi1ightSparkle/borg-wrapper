#!/bin/bash

# This script cannot be run on it's own. From the repo root, run ./borg-wrapper.sh

# Borg wrapper. An (almost) no-dependency wrapper script for basic Borg backup features.
# Copyright (C) 2022-2025  Twilight Sparkle
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

borg_mount() {
    # Required for allow_root
    if
        [[ ! -f "/etc/fuse.conf" ]] ||
        ! grep -E '^user_allow_other$' /etc/fuse.conf > /dev/null
    then
        echo "Error, add user_allow_other to /etc/fuse.conf"
        echo "echo \"user_allow_other\" | sudo tee -a /etc/fuse.conf"
        exit 1
    fi

    # allow_root is needed for the root user to access a backup mounted by
    # a non-root user.
    local CMD=("borg" "mount" "-o" "ro,allow_root")

    local STR
    if [ -n "$BORG_NAME" ]; then
        CMD+=("$BORG_REPO::$BORG_NAME")
        STR="backup $BORG_REPO::$BORG_NAME"
    else
        CMD+=("$BORG_REPO")
        STR="backup repo $BORG_REPO"
    fi

    log 1 0 "Mounting $STR to path $MOUNT_PATH"

    if [ ! -d "$MOUNT_PATH" ]; then
        log 1 0 "Error, mount directory $MOUNT_PATH does not exist"
        exit 1
    fi

    CMD+=("$MOUNT_PATH")

    log 0 0 "Running command: ${CMD[*]}"
    if ! "${CMD[@]}"; then
        log 1 0 "Failed to mount $STR to path $MOUNT_PATH"
        exit 1
    fi

    log 1 0 "Successfully mounted $STR to path $MOUNT_PATH"
}
