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

source "$SCRIPT_DIR/src/help.sh"
source "$SCRIPT_DIR/src/parse_args.sh"

# Load and test config file
if [ ! "$CONFIG_DIR" ]; then
    CONFIG_DIR="$SCRIPT_DIR/config"
fi

if [ -d "$CONFIG_DIR" ]; then
    CONFIG_FILE="$CONFIG_DIR/borg.env"
else
    echo -e "$CONFIG_DIR does not exist or is not a directory.\nCopy directory sample.config to config, then edit config files"
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Unable to load config file $CONFIG_FILE"
    exit 1
fi
source "$CONFIG_FILE"

# Set static vars
source "$SCRIPT_DIR/src/set_vars.sh"

# Source functions
source "$SCRIPT_DIR/src/utils.sh"
source "$SCRIPT_DIR/src/borg_backup.sh"
source "$SCRIPT_DIR/src/borg_check.sh"
source "$SCRIPT_DIR/src/borg_compact.sh"
source "$SCRIPT_DIR/src/borg_delete.sh"
source "$SCRIPT_DIR/src/borg_diff.sh"
source "$SCRIPT_DIR/src/borg_info.sh"
source "$SCRIPT_DIR/src/borg_init.sh"
source "$SCRIPT_DIR/src/borg_list.sh"
source "$SCRIPT_DIR/src/borg_mount.sh"
source "$SCRIPT_DIR/src/borg_prune.sh"
source "$SCRIPT_DIR/src/borg_unmount.sh"
source "$SCRIPT_DIR/src/gen_export.sh"

TIME_STAMP=$(iso_time_stamp)
export TIME_STAMP

# Dependency and config check
check_required_programs
check_required_env

if [ "$REMOTE" = "true" ]; then
    test_target_connectivity
fi

# Run function based on supplied command
case "$COMMAND" in
    backup)     dry_run_notice; borg_backup  ;;
    check)                      borg_check   ;;
    compact)                    borg_compact ;;
    delete)     dry_run_notice; borg_delete  ;;
    diff)       name_required;  borg_diff    ;;
    export)                     gen_export   ;;
    info)                       borg_info    ;;
    init)                       borg_init    ;;
    list)                       borg_list    ;;
    mount)      name_required;  borg_mount   ;;
    prune)      dry_run_notice; borg_prune   ;;
    testhook)                   test_webhook ;;
    unmount)                    borg_unmount ;;
esac
