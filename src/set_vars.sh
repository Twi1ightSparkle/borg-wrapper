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

HOSTNAME=$(hostname)

if [ ! "$BORG_BACKUP_PREFIX" ];         then    BORG_BACKUP_PREFIX="$HOSTNAME-";        fi
if [ ! "$BORG_COMPACT_ON_BACKUP" ];     then    BORG_COMPACT_ON_BACKUP=true;            fi
if [ ! "$BORG_KEEP_DAILY" ];            then    BORG_KEEP_DAILY=7;                      fi
if [ ! "$BORG_KEEP_HOURLY" ];           then    BORG_KEEP_HOURLY=2;                     fi
if [ ! "$BORG_KEEP_MONTHLY" ];          then    BORG_KEEP_MONTHLY=12;                   fi
if [ ! "$BORG_KEEP_WEEKLY" ];           then    BORG_KEEP_WEEKLY=4;                     fi
if [ ! "$BORG_KEEP_WITHIN" ];           then    BORG_KEEP_WITHIN=24H;                   fi
if [ ! "$BORG_KEEP_YEARLY" ];           then    BORG_KEEP_YEARLY=-1;                    fi
if [ ! "$BORG_LOG_FILE" ];              then    BORG_LOG_FILE="$SCRIPT_DIR/borg.log";   fi
if [ ! "$BORG_PRUNE_ON_BACKUP" ];       then    BORG_PRUNE_ON_BACKUP=true;              fi

if [ "$BORG_KEYFILE" ]; then
    export BORG_KEY_FILE="$BORG_KEYFILE"
else
    export BORG_KEY_FILE="$SCRIPT_DIR/config/keyfile"
fi

if [ "$BORG_REMOTE" ]; then
    if [ ! "$BORG_REMOTE_PORT" ]; then
        BORG_REMOTE_PORT=22
    fi
    export BORG_REPO="$BORG_REMOTE_USER@$BORG_REMOTE_DOMAIN:$BORG_TARGET_DIRECTORY"
    export BORG_RSH="ssh -i $BORG_SSH_PRIVKEY -p $BORG_REMOTE_PORT"
else
    export BORG_REPO="$BORG_TARGET_DIRECTORY"
fi

export BORG_PASSPHRASE="$BORG_BACKUP_PASSPHRASE"
