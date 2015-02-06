#!/bin/bash

## -------------------------------------------------------------
## General
## -------------------------------------------------------------
MODULE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
TMP_DIR="$MODULE_DIR/tmp"

# Interrupt the script on first error
set -e

# Import tools
. $DOT_DIR/shell/tools.bash

# Header
print_main_module_header


## -------------------------------------------------------------
## Dependencies
## -------------------------------------------------------------
print_header "Installing Ubuntu packages"
sudo apt-get install ccache
print_status "Done!"


## -------------------------------------------------------------
## Installation
## -------------------------------------------------------------
print_header "Creating links to binaries"
# dot_link_bin $MODULE_DIR """
print_status "Done!"


## -------------------------------------------------------------
print_header "Creating links to config files"
dot_link_config $MODULE_DIR ".local/share/applications/*.desktop"
dot_link_config $MODULE_DIR ".local/share/icons/*.png"
dot_link_config $MODULE_DIR ".local/share/wallpapers/*.png"
print_status "Done!"


# Footer
print_main_module_footer
