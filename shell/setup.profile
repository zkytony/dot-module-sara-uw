# -*- mode: sh -*-
## ----------------------------------------------------------
## Executed for interactive and non-interactive login
## sessions for any POSIX shell.
## ----------------------------------------------------------

# Load sara root from the config file
eval "export SARA_ROOT=$(cat $DOT_MODULE_DIR/sara_root.conf)"

# Setup ccache
export PATH="/usr/lib/ccache:$PATH"

# Some libs might get installed there
export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"

# Paths to internal tools
export PATH="${DOT_MODULE_DIR}/opt/ec2-api-tools/bin:$PATH"
