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

# Load and test config/borg.env
if [ ! -f "$SCRIPT_DIR/config/borg.env" ]; then
    echo -e "Unable to load config file $SCRIPT_DIR/config/borg.env\nCopy config.sample to config, then edit borg.env"
    exit 1
fi
source "$SCRIPT_DIR/config/borg.env"

# Set static vars
HOSTNAME=$(hostname)
export BORG_PASSPHRASE="$BORG_BACKUP_PASSPHRASE"
if [ "$2" = "automated" ]; then
    export AUTOMATED=1
fi

# Set log file path
if [[ ! "$BORG_LOG_FILE" ]]; then
    BORG_LOG_FILE="$SCRIPT_DIR/borg.log"
fi

# Set key file path
if [[ "$BORG_KEYFILE" ]]; then
    export BORG_KEY_FILE="$BORG_KEYFILE"
else
    export BORG_KEY_FILE="$SCRIPT_DIR/config/keyfile"
fi

# Set borg repo
if [[ "$BORG_REMOTE" ]]; then
    export BORG_REPO="$BORG_REMOTE_USER@$BORG_REMOTE_DOMAIN:$BORG_TARGET_DIRECTORY"
else
    export BORG_REPO="$BORG_TARGET_DIRECTORY"
fi

# Source functions
source "$SCRIPT_DIR/src/utils.sh"
source "$SCRIPT_DIR/src/borg_backup.sh"
source "$SCRIPT_DIR/src/borg_compact.sh"
source "$SCRIPT_DIR/src/borg_init.sh"
source "$SCRIPT_DIR/src/borg_list.sh"
source "$SCRIPT_DIR/src/borg_mount.sh"
source "$SCRIPT_DIR/src/borg_prune.sh"
source "$SCRIPT_DIR/src/borg_unmount.sh"

TIME_STAMP=$(iso_time_stamp)
export TIME_STAMP

# Dependency and config check
check_required_programs
check_required_env

# Handle command line params
if [ "$1" = "backup" ]; then
    borg_backup
elif [ "$1" = "compact" ]; then
    borg_compact
elif [ "$1" = "init" ]; then
    borg_init
elif [ "$1" = "list" ]; then
    borg_list
elif [ "$1" = "mount" ]; then
    borg_mount
elif [ "$1" = "prune" ]; then
    borg_prune
elif [ "$1" = "unmount" ]; then
    borg_unmount
elif [ "$1" = "testhook" ]; then
    test_webhook
elif [ "$1" = "version" ]; then
    echo "$PROGRAM_NAME $PROGRAM_VERSION"
    borg --version
else
    print_help
    exit 0
fi
