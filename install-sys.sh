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

# Check if run as root
check_root

# Header
print_main_module_header


## -------------------------------------------------------------
## Installation
## -------------------------------------------------------------

## -------------------------------------------------------------
print_header "Running apt-get update"
apt-get update
print_status "Done!"

## -------------------------------------------------------------
print_header "Installing basic Ubuntu packages"
apt-get install build-essential ccache cmake python-setuptools python3-setuptools
print_status "Done!"


## -------------------------------------------------------------
print_header "Installing system-wide config files"
# CUDA Initialization (harmless on systems without NVidia)
dot_copy_config_sys $DOT_MODULE_DIR "etc/init.d/cuda_init"
dot_copy_config_sys $DOT_MODULE_DIR "etc/rc2.d/S99cuda_init"
chmod a+x /etc/init.d/cuda_init
# Done
print_status "Done!"


## -------------------------------------------------------------
print_header "Installing ROS"
if [ "$(lsb_release -cs)" == "trusty" ]
then
    print_status "Installing ROS using Ubuntu Trusty packages"
    #
    print_status "\nAdding ROS repositories..."
    sh -c 'echo "deb http://packages.ros.org/ros/ubuntu trusty main" > /etc/apt/sources.list.d/ros-latest.list'
    wget https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -O - | sudo apt-key add -
    apt-get update
    #
    print_status "\nInstalling ROS packages..."
    sudo apt-get install ros-indigo-catkin ros-indigo-ros python-wstool
    #
    print_status "\nInstalling rosdep..."
    if [ -f /etc/ros/rosdep/sources.list.d/20-default.list ]
    then
        rm /etc/ros/rosdep/sources.list.d/20-default.list
    fi
    rosdep init
    # Done!
    print_status "Done!"
else
    print_warning "You are not running Ubuntu 14.04 Trusty. Your ROS will be installed from source in the install.sh."
fi


## -------------------------------------------------------------
print_header "Installing rosdep and wstool"
if [[ -e /usr/bin/rosdep && -e /usr/bin/wstool ]]
then
    print_status "Your rosdep and wstool are already installed system-wide! Doing nothing!"
else
    pip install -U rosdep rosinstall_generator wstool rosinstall
    print_status "Done!"
fi


## -------------------------------------------------------------
## Finishing
## -------------------------------------------------------------
print_main_module_footer
unset DOT_MODULE_DIR
