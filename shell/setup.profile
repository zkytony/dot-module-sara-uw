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
# LD_LIBRARY_PATH is not used in Ubuntu, use /etc/ld.so.conf.d instead.
# export LD_LIBRARY_PATH="/usr/local/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"

# Paths to internal tools
export PATH="${DOT_MODULE_DIR}/opt/ec2-api-tools/bin:$PATH"

# Paths to Morse
export PATH="${DOT_MODULE_DIR}/opt/morse/bin:$PATH"
export PYTHONPATH="${DOT_MODULE_DIR}/opt/morse/lib/python3.4/site-packages:${DOT_MODULE_DIR}/opt/morse/lib/python3.5/site-packages:${DOT_MODULE_DIR}/opt/morse/lib/python3/dist-packages:$PYTHONPATH"
