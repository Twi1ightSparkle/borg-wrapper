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

gen_export() {
    if [ "$LIVE" != true ]; then
        echo "This command will display your backup passphrase. Pass --live to show"
        exit 0
    fi

    local STRING="$PROGRAM_NAME

To manually run borg commands, copy the below export commands and paste them into your shell.
Note the leading space. This prevents the command from being saved on your history in many shells.

 export BORG_KEY_FILE=\"$BORG_KEY_FILE\"
 export BORG_PASSPHRASE=\"$BORG_PASSPHRASE\"
 export BORG_REPO=\"$BORG_REPO\""

    if [ "$REMOTE" = "true" ]; then
        STRING+="\n export BORG_RSH=\"$BORG_RSH\""
    fi

    STRING+="\n\nborg list --last 2"

    if [ "$REMOTE" = "true" ]; then
        STRING+="\n\nSSH command: $BORG_RSH $REMOTE_USER@$REMOTE_DOMAIN"
    fi

    echo -e "$STRING"
}
