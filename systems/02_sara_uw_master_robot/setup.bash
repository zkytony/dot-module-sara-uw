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
export MIRA_PATH=${SARA_ROOT}/sara_ws/src:${MIRA_PATH}

# ROS networking
export ROS_MASTER_URI=http://128.208.7.254:11311

# Get wired and wireless IP
ip_wired=""
ip_wireless=""
for dev in $(ls /sys/class/net/)
do
    # Consider only real devices that are up
    if [ -e /sys/class/net/$dev/device ] && [ "$(cat /sys/class/net/$dev/operstate)" == "up" ]
    then
        if [ -e /sys/class/net/$dev/wireless ]
        then
            ip_wireless=$(/sbin/ifconfig $dev 2> /dev/null | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}')
        else
            ip_wired=$(/sbin/ifconfig $dev 2> /dev/null | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}')
        fi
    fi
done

# Set ROS hostname, prefer wired
if [ -n "$ip_wired" ]
then
    export ROS_HOSTNAME="$ip_wired"
else
    export ROS_HOSTNAME="$ip_wireless"
fi
