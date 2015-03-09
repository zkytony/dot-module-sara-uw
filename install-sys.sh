#!/bin/bash

dot_shell=$(cd "${0%/*}/../../shell" && pwd); . "$dot_shell/install_module_header.sh"
check_root  # Check if run as root


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
dot_copy_config_sys $DOT_MODULE_DIR "etc/init.d/cuda-init"
dot_copy_config_sys $DOT_MODULE_DIR "etc/rc2.d/S99cuda-init"
chmod a+x /etc/init.d/cuda-init
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
## Done!
## -------------------------------------------------------------
. "$dot_shell/install_module_footer.sh"
