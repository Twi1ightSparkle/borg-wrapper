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

print_help() {
    cat <<EOF
$PROGRAM_NAME

Usage: ./borg-wrapper.sh <command> [options]

commands:
    -b, --backup       Create new backup
    -V, --check        Check/verify the consistency of a repository or a backup if the backup_name option is set
    -c, --compact      Free up repository space by compacting segments
    -D, --delete       Delete backup(s). Optionally set --name to delete a specific backup.
                       If not, all backups matching BACKUP_PREFIX will be deleted
    -d, --diff         Diff two backups. Specify the 1st backup with --name and the 2nd backup with --path
    -e, --export       Generate exports commands to run borg commands manually
    -h, --help         This help text
    -i, --info         Display detailed information about the repo or a specific backup if --name is specified
    -I, --init         Initialize a new backup repository
    -l, --list         List all backups. Specify the --name option to list files in a specific backup
    -m, --mount        Mount repo. --path must be specified. Optionally set --name to mount a specific backup.
    -p, --prune        Prunes the repository by deleting all archives not
                       matching any of the specified retention options
    -t, --testhook     Test webhook (if enabled in the config)
    -u, --unmount      Unmount the mounted backup. Specify the mount point with --path
    -v, --version      Print version number

options:
    -a, --automated    Disable most log messages to the console
    -C, --config PATH  Full path to config directory. Default scriptDirectory/config
    -n, --name NAME    Name of a backup
    -P, --path PATH    Path to (un)mount OR the 2nd backup name to diff with
        --live         Confirm running destructive changes. See below
                       Check the log file for dry-run details

Dry-run mode:
    The following commands default to running in dry-run mode. Details are saved into the log file.
    Pass --live option to execute.
        --backup
        --delete
        --export
        --prune

Additional documentation in the README.md file or at
https://github.com/Twi1ightSparkle/borg-wrapper

Maintained by Twilight Sparkle
Version $PROGRAM_VERSION
EOF
}
