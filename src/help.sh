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

print_help() {
    cat <<EOF
$PROGRAM_NAME

Usage: ./borg.sh <command> [options] [name]

commands:
    -b, --backup            Create new backup
    -c, --compact           Free up repository space by compacting segments
    -d, --diff NAME2        Diff backup NAME2 and name
    -D, --delete            Delete backup(s). name option can be specified.
                            If not, backups matching BORG_BACKUP_PREFIX will be deleted
    -i, --info              Display detailed information about the repo or a backup if name is specified
    -I, --init              Initialize a new backup repository
    -l, --list              List all backups. Specify name option to list files in a specific backup
    -m, --mount PATH        Mount backup at PATH. name option must be specified
    -p, --prune             Prunes the repository by deleting all archives not
                            matching any of the specified retention options
    -u, --unmount           Unmount the mounted backup

options:
    -a, --automated         Disable most log messages to the console
    -C, --config            Full path to config (env) file
    -h, --help              This help text
    --live                  Confirm running certain destructive changes. Runs a dry-run if not set
                            Check the log file for dry-run details
    -t, --testhook          Test webhook (if enabled in the config)
    -v, --version           Print version number

Additional documentation in the README.md file or at
https://github.com/twi1ightsparkle/borg

Maintained by Twilight Sparkle
Version $PROGRAM_VERSION
EOF
}
