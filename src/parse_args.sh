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
    -a | --automated)   export param_automated=true;    shift           ;;
    -b | --backup)      export param_backup=true;       shift           ;;
    -c | --compact)     export param_compact=true;      shift           ;;
    -C | --config)      export BORG_CONFIG_PATH="$2";   shift; shift    ;;
    -d | --diff)        export param_diff="$2";         shift           ;;
    -D | --delete)      export param_delete=true;       shift           ;;
    -h | --help)        print_help;                     exit 0          ;;
    -i | --info)        export param_info=true;         shift           ;;
    -I | --init)        export param_init=true;         shift           ;;
    -l | --list)        export param_list=true;         shift           ;;
    --live)             LIVE=true;                      shift           ;;
    -m | --mount)       export param_mount="$2"         shift; shift    ;;
    -p | --prune)       export param_prune=true;        shift           ;;
    -t | --testhook)    export param_testhook=true;     shift           ;;
    -u | --unmount)     export param_unmount="$2";      shift; shift    ;;
    -v | --version)     export param_version=true;      shift           ;;
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
