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
# Load sara root from the config file
eval "export SARA_ROOT=$(cat $DOT_MODULE_DIR/sara_root.conf)"

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
print_header "Installing EC2 API tools"
print_status "Downloading..."
cd ${TMP_DIR}
rm -rf ec2-api-tools.zip
wget http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip
print_status "\nObtaining version..."
ec2_ver=$(unzip -v ec2-api-tools.zip | grep -G "ec2-api-tools-[0-9\.]*/$")
ec2_ver=${ec2_ver##*ec2-api-tools-}
ec2_ver=${ec2_ver%%/*}
print_status "\nInstalling verision $ec2_ver..."
rm -rf ec2-api-tools-$ec2_ver
unzip -q ec2-api-tools.zip
rm -rf "${DOT_MODULE_DIR}/opt/ec2-api-tools"
mv ec2-api-tools-$ec2_ver "${DOT_MODULE_DIR}/opt/ec2-api-tools"
print_status "Done!"


## -------------------------------------------------------------
print_header "Updating rosdep"
rosdep update
print_status "Done!"


## -------------------------------------------------------------
print_header "Checking SARA path"
if [ -z "$SARA_ROOT" ]
then
    print_error "SARA_ROOT environment variable is not set!"
    exit 1
fi
print_status "Done!"


## -------------------------------------------------------------
print_header "Installing ROS"
if [ -f /opt/ros/indigo/setup.bash ]
then
    print_status "Your ROS is already installed system-wide! Doing nothing!"
else
    if [ "$(lsb_release -cs)" == "utopic" ]
    then
        print_status "Installing ROS from sources..."
        if [ -f "$SARA_ROOT/ros_ws/src/.rosinstall" ]
        then
            print_status "Existing ROS source installation exists. Updating..."
            rm "$SARA_ROOT/ros_ws/src/.rosinstall"
        fi
        # Clean all existing ros env vars to start with clean slate
        unset ROS_ROOT
        unset ROS_PACKAGE_PATH
        unset ROSCONSOLE_CONFIG_FILE
        unset ROS_TEST_RESULTS_DIR
        unset ROS_MAVEN_DEPLOYMENT_REPOSITORY
        unset ROS_MAVEN_PATH
        unset ROS_MAVEN_REPOSITORY
        unset ROS_DISTRO
        unset ROS_ETC_DIR
        #
        print_status "\nInitializing workspace..."
        mkdir -p "$SARA_ROOT/ros_ws/src"
        cd "$SARA_ROOT/ros_ws"
        rosinstall_generator desktop perception navigation slam_gmapping audio_common openni2_launch robot_pose_publisher dynamixel_motor depthimage_to_laserscan yujin_ocs kobuki usb_cam rosbridge_suite openni_launch prosilica_camera warehouse_ros hokuyo_node joystick_drivers robot_localization --rosdistro indigo --deps --wet-only --tar > "$SARA_ROOT/ros_ws/sara_ros.rosinstall"
        wstool init -j4 "$SARA_ROOT/ros_ws/src" "$SARA_ROOT/ros_ws/sara_ros.rosinstall"
        #
        print_status "\nChecking for missing dependencies..."
        # The following will result in an error about rosdep etc. so we add || true
        rosdep install --from-paths src -y -i -r --os ubuntu:trusty || true
        #
        print_status "\nCompiling..."
        ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release
        # Done
        print_status "Done!"
    else
        print_error "You are not on Ubuntu Utopic 14.10 and have no system-wide ROS installation."
        print_info "You could have forgotten to run install-sys.sh which installs ROS on Trusty."
        print_info "Other systems than Ubuntu Trusty and Utopic are NOT supported!"
        exit 1
    fi
fi


## -------------------------------------------------------------
print_header "Installing custom ROS packages"
if [ -f "$SARA_ROOT/ros_custom_ws/src/.rosinstall" ]
then
    print_status "Existing installation exists. Updating..."
    rm "$SARA_ROOT/ros_custom_ws/src/.rosinstall"
fi
print_status "\nInitializing workspace..."
mkdir -p "$SARA_ROOT/ros_custom_ws/src"
cd "$SARA_ROOT/ros_custom_ws"
wstool init -j4 "$SARA_ROOT/ros_custom_ws/src" "$DOT_MODULE_DIR/rosinstall/sara_ros_custom.rosinstall"
print_status "\nChecking for missing dependencies..."
if [ -f /opt/ros/indigo/setup.bash ]
then
    source /opt/ros/indigo/setup.bash
else
    source "$SARA_ROOT/ros_ws/install_isolated/setup.bash"
fi
rosdep install --from-paths src -i -y
print_status "\nCompiling..."
catkin_make -DCMAKE_BUILD_TYPE=Release
# Done
print_status "Done!"


## -------------------------------------------------------------
print_header "Installing ROSJava packages"
if [ -f "$SARA_ROOT/rosjava_ws/src/.rosinstall" ]
then
    print_status "Existing installation exists. Updating..."
    rm "$SARA_ROOT/rosjava_ws/src/.rosinstall"
fi
print_status "\nInitializing workspace..."
mkdir -p "$SARA_ROOT/rosjava_ws/src"
cd "$SARA_ROOT/rosjava_ws"
wstool init -j4 "$SARA_ROOT/rosjava_ws/src" "$DOT_MODULE_DIR/rosinstall/sara_rosjava.rosinstall"
print_status "\nChecking for missing dependencies..."
source "$SARA_ROOT/ros_custom_ws/devel/setup.bash"
rosdep install --from-paths src -i -y
print_status "\nCompiling..."
catkin_make -DCMAKE_BUILD_TYPE=Release
# Done
print_status "Done!"



## -------------------------------------------------------------
## Finishing
## -------------------------------------------------------------
print_main_module_footer
unset DOT_MODULE_DIR
