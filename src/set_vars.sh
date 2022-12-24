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

HOSTNAME=$(hostname)

# Set config defaults if not specified in the env file
if [ ! "$BACKUP_PREFIX" ];     then BACKUP_PREFIX="$HOSTNAME-";      fi
if [ ! "$COMPACT_ON_BACKUP" ]; then COMPACT_ON_BACKUP=true;          fi
if [ ! "$KEEP_DAILY" ];        then KEEP_DAILY=7;                    fi
if [ ! "$KEEP_HOURLY" ];       then KEEP_HOURLY=2;                   fi
if [ ! "$KEEP_MONTHLY" ];      then KEEP_MONTHLY=12;                 fi
if [ ! "$KEEP_WEEKLY" ];       then KEEP_WEEKLY=4;                   fi
if [ ! "$KEEP_WITHIN" ];       then KEEP_WITHIN=24H;                 fi
if [ ! "$KEEP_YEARLY" ];       then KEEP_YEARLY=-1;                  fi
if [ ! "$KEYFILE_IN_REPO" ];   then KEYFILE_IN_REPO=false;           fi
if [ ! "$LOG_FILE" ];          then LOG_FILE="$CONFIG_DIR/borg.log"; fi
if [ ! "$ONE_FILE_SYSTEM" ];   then ONE_FILE_SYSTEM=true;            fi
if [ ! "$PRUNE_ON_BACKUP" ];   then PRUNE_ON_BACKUP=true;            fi
if [ ! "$REMOTE" ];            then REMOTE=false;                    fi
if [ ! "$WEBHOOK_ENABLED" ];   then WEBHOOK_ENABLED=false;           fi
if [ ! "$WEBHOOK_VERBOSE" ];   then WEBHOOK_VERBOSE=true;            fi

# Set and verify files
MISSING=""
if [ ! "$BACKUP_PASSPHRASE_FILE" ]; then BACKUP_PASSPHRASE_FILE="$CONFIG_DIR/borg_passphrase"; fi
if [ ! -f "$BACKUP_PASSPHRASE_FILE" ];
    then MISSING+="\n- Passphrase file $BACKUP_PASSPHRASE_FILE does not exist or is not a file";
fi

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
    export BORG_KEY_FILE_PATH="$KEYFILE"
else
    export BORG_KEY_FILE_PATH="$CONFIG_DIR/keyfile";
fi

if [ "$KEYFILE_IN_REPO" != "true" ]; then
    export BORG_KEY_FILE="$BORG_KEY_FILE_PATH"
fi

# Export borg environment options
if [ "$REMOTE" = "true" ]; then
    if [ ! "$REMOTE_PORT" ]; then REMOTE_PORT=22; fi
    export BORG_REPO="$REMOTE_USER@$REMOTE_DOMAIN:$TARGET_DIRECTORY"
    export BORG_RSH="ssh -i $REMOTE_SSH_PRIVKEY -p $REMOTE_PORT"
else
    export BORG_REPO="$TARGET_DIRECTORY"
fi

BORG_PASSPHRASE="$(head -n 1 "$BACKUP_PASSPHRASE_FILE")"
if [ ! "$BORG_PASSPHRASE" ];
    then echo "Your passphrase cannot be empty. Add a secure passphrase to $BACKUP_PASSPHRASE_FILE"
    exit 1
fi
export BORG_PASSPHRASE
