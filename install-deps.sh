#!/bin/bash

## -------------------------------------------------------------
## General
## -------------------------------------------------------------
MODULE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
TMP_DIR="$MODULE_DIR/tmp"

# Interrupt the script on first error
set -e

# Header
echo "==============================="
echo "Dotfiles Module Deps Installer "
echo "==============================="
echo "Using dot files in: ${DOT_DIR}"


## -------------------------------------------------------------
## Installation
## -------------------------------------------------------------
echo
echo "-------------------------------"
echo "Installing basic packages"
echo "-------------------------------"
# sudo apt-get install ccache


echo
echo "-------------------------------"
echo "All done! "
echo "-------------------------------"
