#!/bin/bash

## -------------------------------------------------------------
## General
## -------------------------------------------------------------
# Set paths
export DOT_MODULE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
if [ -z "$DOT_DIR" ]
then
   export DOT_DIR=$( readlink -f $DOT_MODULE_DIR/../.. )
fi
TMP_DIR="$DOT_MODULE_DIR/tmp"

# Interrupt the script on first error
set -e

# Import tools
. $DOT_DIR/shell/tools.bash

# Check if not run as root
check_not_root

# Header
print_main_module_header


## -------------------------------------------------------------
## Installation
## -------------------------------------------------------------

## -------------------------------------------------------------
print_header "Creating links to binaries"
# dot_link_bin $DOT_MODULE_DIR """
print_status "Done!"


## -------------------------------------------------------------
print_header "Installing user-local config files"
# VNC client
dot_link_config $DOT_MODULE_DIR ".vnc/profiles/sara_uw_dube.vnc"
dot_link_config $DOT_MODULE_DIR ".vnc/profiles/sara_uw_ec2_sim.vnc"
# Shortcuts
dot_link_config $DOT_MODULE_DIR ".local/share/applications/*.desktop"
# SSH
dot_prepend_to_config $DOT_MODULE_DIR ".ssh/config" "# dot-module-sara-uw configuration begins here" "# dot-module-sara-uw configuration ends here"
# Art
dot_link_config $DOT_MODULE_DIR ".local/share/icons/*.png"
dot_link_config $DOT_MODULE_DIR ".local/share/wallpapers/*.png"
# Done
print_status "Done!"


## -------------------------------------------------------------
## Finishing
## -------------------------------------------------------------
print_main_module_footer
unset DOT_MODULE_DIR
