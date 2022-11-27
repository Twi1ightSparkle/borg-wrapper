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

# Print help text
print_help() {
    cat <<EOF
$PROGRAM_NAME

Usage: ./borg.sh <command> [options] [name]

commands:
    -b, --backup            Create new backup
    -c, --compact           Free up repository space by compacting segments
    -d, --diff NAME2        Diff backup NAME2 and name
    -D, --delete            Delete backup with ID. name option must be specified
    -i, --init              Initialize a new backup repository
    -l, --list              List all backups. Specify name option to list files in a specific backup
    -m, --mount PATH        Mount backup at PATH. name option must be specified
    -p, --prune             Prunes the repository by deleting all archives not
    -u, --unmount           Unmount the mounted backup

options:
    -a, --automated         Disable most log messages to the console
    -C, --config            Full path to config (env) file
    -h, --help              This help text
                            matching any of the specified retention options
    -t, --testhook          Test webhook (if enabled in the config)
    -v, --version           Print version number

Additional documentation in the README.md file or at
https://github.com/twi1ightsparkle/borg

Maintained by Twilight Sparkle
Version $PROGRAM_VERSION
EOF
}

source "$SCRIPT_DIR/src/parse_args.sh"

# Load and test config/borg.env
if [ ! "$BORG_CONFIG_PATH" ]; then
    BORG_CONFIG_PATH="$SCRIPT_DIR/config/borg.env"
fi
if [ ! -f "$BORG_CONFIG_PATH" ]; then
    echo -e "Unable to load config file $BORG_CONFIG_PATH\nCopy config.sample to config, then edit borg.env"
    exit 1
fi
source "$BORG_CONFIG_PATH"

# Set static vars
source "$SCRIPT_DIR/src/set_vars.sh"

# Source functions
source "$SCRIPT_DIR/src/utils.sh"
source "$SCRIPT_DIR/src/borg_backup.sh"
source "$SCRIPT_DIR/src/borg_compact.sh"
source "$SCRIPT_DIR/src/borg_delete.sh"
source "$SCRIPT_DIR/src/borg_diff.sh"
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

if [ "$BORG_REMOTE" ]; then
    test_target_connectivity
fi

# Run functions based on supplied command line option
if [ "$param_version" ]; then
    echo "$PROGRAM_NAME $PROGRAM_VERSION"
    borg --version
elif [ "$param_backup" ]; then
    borg_backup
elif [ "$param_compact" ]; then
    borg_compact
elif [ "$param_delete" ]; then
    name_required
    borg_delete
elif [ "$param_diff" ]; then
    name_required
    borg_diff
elif [ "$param_init" ]; then
    borg_init
elif [ "$param_list" ]; then
    borg_list
elif [ "$param_mount" ]; then
    name_required
    borg_mount
elif [ "$param_prune" ]; then
    borg_prune
elif [ "$param_unmount" ]; then
    borg_unmount
elif [ "$param_testhook" ]; then
    test_webhook
else
    print_help
fi
