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

source "$SCRIPT_DIR/src/help.sh"
source "$SCRIPT_DIR/src/parse_args.sh"

# Load and test config/borg.env
if [ ! "$CONFIG_DIR" ]; then
    CONFIG_PATH="$SCRIPT_DIR/config/borg.env"
elif [ -d "$CONFIG_DIR" ]; then
    CONFIG_PATH="$CONFIG_DIR/borg.env"
else
    CONFIG_PATH="$CONFIG_DIR"
fi
if [ ! -f "$CONFIG_PATH" ]; then
    echo -e "Unable to load config file $CONFIG_PATH\nCopy config.sample to config, then edit borg.env"
    exit 1
fi
source "$CONFIG_PATH"

# Set static vars
source "$SCRIPT_DIR/src/set_vars.sh"

# Source functions
source "$SCRIPT_DIR/src/utils.sh"
source "$SCRIPT_DIR/src/borg_backup.sh"
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

if [ "$REMOTE" ]; then
    test_target_connectivity
fi

# Run function based on supplied command
case "$COMMAND" in
    backup)     dry_run_notice; borg_backup  ;;
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
