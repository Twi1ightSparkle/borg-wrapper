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

POSITIONAL_ARGS=()

# If no command line arguments were passed
if [ $# = 0 ]; then
    print_help
    exit 0
fi

LIVE=false

while [ $# -gt 0 ]; do
    case $1 in
    -a | --automated)   export ARG_AUTOMATED=true;    shift           ;;
    -b | --backup)      export ARG_BACKUP=true;       shift           ;;
    -c | --compact)     export ARG_COMPACT=true;      shift           ;;
    -C | --config)      export ARG_CONFIG="$2";       shift; shift    ;;
    -d | --diff)        export ARG_DIFF="$2";         shift           ;;
    -D | --delete)      export ARG_DELETE=true;       shift           ;;
    -e | --export)      export ARG_EXPORT=true;       shift           ;;
    -h | --help)        print_help;                   exit 0          ;;
    -i | --info)        export ARG_INFO=true;         shift           ;;
    -I | --init)        export ARG_INIT=true;         shift           ;;
    -l | --list)        export ARG_LIST=true;         shift           ;;
    --live)             LIVE=true;                    shift           ;;
    -m | --mount)       export ARG_MOUNT="$2"         shift; shift    ;;
    -p | --prune)       export ARG_PRUNE=true;        shift           ;;
    -t | --testhook)    export ARG_TESTHOOK=true;     shift           ;;
    -u | --unmount)     export ARG_UNMOUNT="$2";      shift; shift    ;;
    -v | --version)     export ARG_VERSION=true;      shift           ;;
    -*)
        echo "Unknown option $1."
        print_help
        exit 1
        ;;
    *)
        POSITIONAL_ARGS+=("$1") # save positional arg
        shift                   # past argument
        ;;
    esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters
export NAME="$2"
export LIVE
