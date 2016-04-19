# -*- mode: sh -*-
## ----------------------------------------------------------
## Executed for interactive, login and non-login
## Bash sessions.
## ----------------------------------------------------------

# SARA
if [ -d $SARA_ROOT ]
then
    source $SARA_ROOT/sara_ws/devel/setup.bash
fi

# ROS configuration
export ROSCONSOLE_FORMAT='[${severity}] [${node}@${function}:${line}]: ${message}'

# MIRA configuration
export MIRA_PATH=/opt/MIRA
export LD_LIBRARY_PATH=/opt/MIRA/lib:${LD_LIBRARY_PATH}
export PATH=/opt/MIRA/bin:${PATH}
export MIRA_PATH=/opt/MIRA-commercial:${MIRA_PATH}
export LD_LIBRARY_PATH=/opt/MIRA-commercial/lib:${LD_LIBRARY_PATH}
export MIRA_PATH=${SARA_ROOT}/sara_ws/src/sara_scitos/sara_mira:${MIRA_PATH}

# ROS networking
export ROS_MASTER_URI=http://localhost:11311
export ROS_HOSTNAME=localhost
