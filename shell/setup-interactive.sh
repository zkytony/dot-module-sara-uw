# -*- mode: sh -*-
## ----------------------------------------------------------
## Executed for interactive, login and non-login
## sessions for any POSIX shell.
## ----------------------------------------------------------

## ---------------------------
## Aliases
## ---------------------------
alias sara="cd $SARA_ROOT/sara_ws/src"
if [ -f /opt/ros/indigo/setup.bash ]
then
    alias ros="cd /opt/ros/indigo"
else
    alias ros="cd $SARA_ROOT/ros_ws/src"
fi

## ---------------------------
## Ping Aliases
## ---------------------------
alias ping-dube='ping 128.208.7.254'
