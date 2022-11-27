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

HOSTNAME=$(hostname)

# Set config defaults if not specified in the env file
if [ ! "$BACKUP_PREFIX" ];         then    BACKUP_PREFIX="$HOSTNAME-";        fi
if [ ! "$COMPACT_ON_BACKUP" ];     then    COMPACT_ON_BACKUP=true;            fi
if [ ! "$KEEP_DAILY" ];            then    KEEP_DAILY=7;                      fi
if [ ! "$KEEP_HOURLY" ];           then    KEEP_HOURLY=2;                     fi
if [ ! "$KEEP_MONTHLY" ];          then    KEEP_MONTHLY=12;                   fi
if [ ! "$KEEP_WEEKLY" ];           then    KEEP_WEEKLY=4;                     fi
if [ ! "$KEEP_WITHIN" ];           then    KEEP_WITHIN=24H;                   fi
if [ ! "$KEEP_YEARLY" ];           then    KEEP_YEARLY=-1;                    fi
if [ ! "$LOG_FILE" ];              then    LOG_FILE="$CONFIG_DIR/borg.log";   fi
if [ ! "$PRUNE_ON_BACKUP" ];       then    PRUNE_ON_BACKUP=true;              fi

# Set and verify files
MISSING=""
if [ ! "$EXCLUDE_FILE" ]; then EXCLUDE_FILE="$CONFIG_DIR/exclude.txt"; fi
if [ ! -f "$EXCLUDE_FILE" ]; then MISSING+="\n- Exclude file $EXCLUDE_FILE does not exist or is not a file"; fi

if [ ! "$INCLUDE_FILE" ]; then INCLUDE_FILE="$CONFIG_DIR/include.txt"; fi
if [ ! -f "$INCLUDE_FILE" ]; then MISSING+="\n- Include file $INCLUDE_FILE does not exist or is not a file"; fi

# If any errors
if [ -n "$MISSING" ]; then
    echo -e "Required files missing:$MISSING"
    exit 1
fi

export EXCLUDE_FILE
export INCLUDE_FILE

if [ "$KEYFILE" ]; then
    export BORG_KEY_FILE="$KEYFILE"
else
    export BORG_KEY_FILE="$CONFIG_DIR/keyfile";
fi

# Export borg environment options
if [ "$REMOTE" = "true" ]; then
    if [ ! "$REMOTE_PORT" ]; then REMOTE_PORT=22; fi
    export BORG_REPO="$REMOTE_USER@$REMOTE_DOMAIN:$TARGET_DIRECTORY"
    export BORG_RSH="ssh -i $REMOTE_SSH_PRIVKEY -p $REMOTE_PORT"
else
    export BORG_REPO="$TARGET_DIRECTORY"
fi

export BORG_PASSPHRASE="$BACKUP_PASSPHRASE"
