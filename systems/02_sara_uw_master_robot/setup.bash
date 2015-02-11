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

# Network params detection
function get_ip
{
    /sbin/ifconfig $1 2> /dev/null | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'
}

# ROS networking
export ROS_MASTER_URI=http://128.208.7.254:11311

# Check IP in this order: eth0 eth1 wlan0 wlan1
if [ -n "$(get_ip eth0)" ]
then
    export ROS_HOSTNAME="$(get_ip eth0)"
elif [ -n "$(get_ip eth1)" ]
then
    export ROS_HOSTNAME="$(get_ip eth1)"
elif [ -n "$(get_ip wlan0)" ]
then
    export ROS_HOSTNAME="$(get_ip wlan0)"
else
    export ROS_HOSTNAME="$(get_ip wlan1)"
fi
