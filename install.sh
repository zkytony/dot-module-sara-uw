#!/bin/bash

## -------------------------------------------------------------
## General
## -------------------------------------------------------------
MODULE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Interrupt the script on first error
set -e

# Import tools
. $DOT_DIR/shell/tools.bash

# Header
echo "==============================="
echo "Dotfiles Module Installer "
echo "==============================="
echo "Using dot files in: ${DOT_DIR}"


## -------------------------------------------------------------
## Installation
## -------------------------------------------------------------
echo
echo "-------------------------------"
echo "Creating links to binaries "
echo "-------------------------------"
# dot_link_bin $MODULE_DIR """
echo "Done!"


echo
echo "-------------------------------"
echo "Creating links to config files "
echo "-------------------------------"
# dot_link_config $MODULE_DIR ""
echo "Done!"


echo
echo "-------------------------------"
echo "All done! "
echo "-------------------------------"
