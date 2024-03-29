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

POSITIONAL_ARGS=()

# If no command line arguments were passed
if [ "$#" = 0 ]; then
    print_help
    exit 0
fi

LIVE=false
COUNT=0

while [ "$#" -gt 0 ]; do
    case $1 in
        # commands
        -h | --help)     print_help; exit 0 ;;
        -v | --version)  echo "$PROGRAM_NAME $PROGRAM_VERSION"; borg --version; exit 0 ;;
        -b | --backup)   COMMAND="backup";   COUNT=$((COUNT+1)); shift ;;
        -V | --check)    COMMAND="check";    COUNT=$((COUNT+1)); shift ;;
        -c | --compact)  COMMAND="compact";  COUNT=$((COUNT+1)); shift ;;
        -D | --delete)   COMMAND="delete";   COUNT=$((COUNT+1)); shift ;;
        -d | --diff)     COMMAND="diff";     COUNT=$((COUNT+1)); shift ;;
        -e | --export)   COMMAND="export";   COUNT=$((COUNT+1)); shift ;;
        -i | --info)     COMMAND="info";     COUNT=$((COUNT+1)); shift ;;
        -I | --init)     COMMAND="init";     COUNT=$((COUNT+1)); shift ;;
        -l | --list)     COMMAND="list";     COUNT=$((COUNT+1)); shift ;;
        -m | --mount)    COMMAND="mount";    COUNT=$((COUNT+1)); shift ;;
        -p | --prune)    COMMAND="prune";    COUNT=$((COUNT+1)); shift ;;
        -t | --testhook) COMMAND="testhook"; COUNT=$((COUNT+1)); shift ;;
        -u | --unmount)  COMMAND="unmount";  COUNT=$((COUNT+1)); shift ;;

        # options
        --live)             LIVE=true;              shift        ;;
        -a | --automated)   export AUTOMATED=true;  shift        ;;
        -C | --config)      export CONFIG_DIR="$2"; shift; shift ;;
        -n | --name)        export BORG_NAME="$2";       shift; shift ;;
        -P | --path)        export MOUNT_PATH="$2"; shift; shift ;;

        # Catch unknown arguments
        -*)
            echo "Unknown option $1."
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1") # save positional arg
            shift                   # past argument
            ;;
    esac
done

if [ ! "$COUNT" = 1 ]; then
    echo "Exactly one command must be set"
    exit 1
fi

export COMMAND
export LIVE
