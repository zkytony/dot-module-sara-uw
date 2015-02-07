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
print_header "Installing user-local config files"
# VNC client
dot_link_config $MODULE_DIR ".vnc/profiles/sara_uw_dube.vnc"
dot_link_config $MODULE_DIR ".vnc/profiles/sara_uw_ec2_sim.vnc"
# Shortcuts
dot_link_config $MODULE_DIR ".local/share/applications/*.desktop"
# Art
dot_link_config $MODULE_DIR ".local/share/icons/*.png"
dot_link_config $MODULE_DIR ".local/share/wallpapers/*.png"
# Done
print_status "Done!"


# Footer
print_main_module_footer
