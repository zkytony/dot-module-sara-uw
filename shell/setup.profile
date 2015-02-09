# -*- mode: sh -*-
## --------------------------------------------
## This file is executed for login shells only
## Can be executed with dash
## --------------------------------------------

# Load sara root from the config file
eval "export SARA_ROOT=$(cat $DOT_MODULE_DIR/sara_root.conf)"

# Setup ccache
export PATH="/usr/lib/ccache:$PATH"

# Some libs might get installed there
export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
