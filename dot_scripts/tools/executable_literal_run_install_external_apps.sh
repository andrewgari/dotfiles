#!/bin/bash

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_DIR="$SCRIPT_DIR/../.scripts/bootstrap"

# Execute the external apps bootstrap script
source "$BOOTSTRAP_DIR/external_apps.sh"
install_external_apps 