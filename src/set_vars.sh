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

if [ ! "$BACKUP_PREFIX" ];         then    BACKUP_PREFIX="$HOSTNAME-";        fi
if [ ! "$COMPACT_ON_BACKUP" ];     then    COMPACT_ON_BACKUP=true;            fi
if [ ! "$KEEP_DAILY" ];            then    KEEP_DAILY=7;                      fi
if [ ! "$KEEP_HOURLY" ];           then    KEEP_HOURLY=2;                     fi
if [ ! "$KEEP_MONTHLY" ];          then    KEEP_MONTHLY=12;                   fi
if [ ! "$KEEP_WEEKLY" ];           then    KEEP_WEEKLY=4;                     fi
if [ ! "$KEEP_WITHIN" ];           then    KEEP_WITHIN=24H;                   fi
if [ ! "$KEEP_YEARLY" ];           then    KEEP_YEARLY=-1;                    fi
if [ ! "$LOG_FILE" ];              then    LOG_FILE="$SCRIPT_DIR/borg.log";   fi
if [ ! "$PRUNE_ON_BACKUP" ];       then    PRUNE_ON_BACKUP=true;              fi

if [ "$EXCLUDE_FILE" ]; then
    EXCLUDE_PATH="$EXCLUDE_FILE";
elif [ "$ARG_CONFIG" ]; then
    EXCLUDE_PATH="$ARG_CONFIG/exclude.txt";
else
    EXCLUDE_PATH="$SCRIPT_DIR/config/exclude.txt";
fi
export EXCLUDE_PATH

if [ "$INCLUDE_FILE" ]; then
    INCLUDE_PATH="$INCLUDE_FILE";
elif [ "$ARG_CONFIG" ]; then
    INCLUDE_PATH="$ARG_CONFIG/include.txt";
else
    INCLUDE_PATH="$SCRIPT_DIR/config/include.txt";
fi
export INCLUDE_PATH

if [ "$KEYFILE" ]; then
    export BORG_KEY_FILE="$KEYFILE"
elif [ "$ARG_CONFIG" ]; then
    export BORG_KEY_FILE="$ARG_CONFIG/keyfile";
else
    export BORG_KEY_FILE="$SCRIPT_DIR/config/keyfile"
fi

if [ "$REMOTE" ]; then
    if [ ! "$REMOTE_PORT" ]; then
        REMOTE_PORT=22
    fi
    export BORG_REPO="$REMOTE_USER@$REMOTE_DOMAIN:$TARGET_DIRECTORY"
    export BORG_RSH="ssh -i $REMOTE_SSH_PRIVKEY -p $REMOTE_PORT"
else
    export BORG_REPO="$TARGET_DIRECTORY"
fi

export BORG_PASSPHRASE="$BACKUP_PASSPHRASE"
