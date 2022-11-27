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
if [ ! "$param_config" ]; then
    CONFIG_PATH="$SCRIPT_DIR/config/borg.env"
elif [ -d "$param_config" ]; then
    CONFIG_PATH="$param_config/borg.env"
else
    CONFIG_PATH="$param_config"
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

# Run functions based on supplied command line option
if [ "$param_version" ]; then
    echo "$PROGRAM_NAME $PROGRAM_VERSION"
    borg --version
elif [ "$param_backup" ]; then
    dry_run_notice
    borg_backup
elif [ "$param_compact" ]; then
    borg_compact
elif [ "$param_delete" ]; then
    dry_run_notice
    borg_delete
elif [ "$param_diff" ]; then
    name_required
    borg_diff
elif [ "$param_info" ]; then
    borg_info
elif [ "$param_export" ]; then
    gen_export
elif [ "$param_init" ]; then
    borg_init
elif [ "$param_list" ]; then
    borg_list
elif [ "$param_mount" ]; then
    name_required
    borg_mount
elif [ "$param_prune" ]; then
    dry_run_notice
    borg_prune
elif [ "$param_unmount" ]; then
    borg_unmount
elif [ "$param_testhook" ]; then
    test_webhook
else
    print_help
fi
