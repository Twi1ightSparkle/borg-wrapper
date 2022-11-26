#!/bin/bash

PROGRAM_NAME="Borg backup runner"
PROGRAM_VERSION="0.1.0"
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
source "$SCRIPT_DIR/src/index.sh"
