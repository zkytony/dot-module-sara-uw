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
        #
        print_status "\nInitializing workspace..."
        mkdir -p "$SARA_ROOT/ros_ws/src"
        cd "$SARA_ROOT/ros_ws"
        rosinstall_generator desktop perception navigation slam_gmapping audio_common openni2_launch robot_pose_publisher dynamixel_motor depthimage_to_laserscan yujin_ocs kobuki usb_cam rosbridge_suite openni_launch prosilica_camera warehouse_ros hokuyo_node joystick_drivers robot_localization octomap octomap_msgs --rosdistro indigo --deps --wet-only --tar > "$SARA_ROOT/ros_ws/sara_ros.rosinstall"
        # The true is needed in order to pass through an error that might happen when the tar package
        # versions are updated. Then wstool update will deal with that problem.
        wstool init -j4 "$SARA_ROOT/ros_ws/src" "$SARA_ROOT/ros_ws/sara_ros.rosinstall" || true
        wstool update --delete-changed-uris -t "$SARA_ROOT/ros_ws/src"
        #
        print_status "\nChecking for missing dependencies..."
        # The following will result in an error about rosdep in utopic etc. so we add || true
        rosdep install --from-paths src -y -i -r --os ubuntu:trusty || true
        #
        print_status "\nCompiling..."
        # Use a clean environment to not have any dependencies
        env -i HOME=$HOME bash -c "source /etc/profile; ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
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
# The true is needed in order to pass through an error that might happen when the tar package
# versions are updated. Then wstool update will deal with that problem.
wstool init -j4 "$SARA_ROOT/ros_custom_ws/src" "$DOT_MODULE_DIR/rosinstall/sara_ros_custom.rosinstall" || true
wstool update --delete-changed-uris -t "$SARA_ROOT/ros_custom_ws/src"
print_status "\nChecking for missing dependencies..."
if [ -f /opt/ros/indigo/setup.bash ]
then
    source /opt/ros/indigo/setup.bash
else
    source "$SARA_ROOT/ros_ws/install_isolated/setup.bash"
fi
# The following will result in an error about rosdep in utopic etc. so we add || true
rosdep install --from-paths src -i -y -r --os ubuntu:trusty || true
print_status "\nCompiling..."
catkin_make -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
# Done
print_status "Done!"


## -------------------------------------------------------------
print_header "Installing ROSJava packages"
if [ -f "$SARA_ROOT/rosjava_ws/src/.rosinstall" ]
then
    print_status "Existing installation exists. Updating..."
    rm "$SARA_ROOT/rosjava_ws/src/.rosinstall"
fi
#
print_status "\nInitializing workspace..."
mkdir -p "$SARA_ROOT/rosjava_ws/src"
cd "$SARA_ROOT/rosjava_ws"
# The true is needed in order to pass through an error that might happen when the tar package
# versions are updated. Then wstool update will deal with that problem.
wstool init -j4 "$SARA_ROOT/rosjava_ws/src" "$DOT_MODULE_DIR/rosinstall/sara_rosjava.rosinstall" || true
wstool update --delete-changed-uris -t "$SARA_ROOT/rosjava_ws/src"
#
print_status "\nChecking for missing dependencies..."
source "$SARA_ROOT/ros_custom_ws/devel/setup.bash"
# The following will result in an error about rosdep in utopic etc. so we add || true
rosdep install --from-paths src -i -y -r --os ubuntu:trusty || true
#
print_status "\nCompiling..."
catkin_make -DCMAKE_BUILD_TYPE=Release # -DCMAKE_EXPORT_COMPILE_COMMANDS=ON Not working for rosjava
# Done
print_status "Done!"


## -------------------------------------------------------------
print_header "Selecting SARA setup"
configs=""
for i in ${DOT_MODULE_DIR}/rosinstall/sara_uw*.rosinstall
do
    i=${i##*/rosinstall/}
    n=${i##sara_}
    n=${n%%.rosinstall}
    configs="$configs $i $n"
done
rifile=$(whiptail --title "Select SARA System Setup" --menu "" 20 50 10 ${configs} 3>&2 2>&1 1>&3)
unset configs
if [ -z "$rifile" ]
then
    print_error "No configuration selected! Aborting!"
    exit 1
fi
print_status "Using system setup in ${rifile}."
mkdir -p "$SARA_ROOT/sara_ws"
cp "$DOT_MODULE_DIR/rosinstall/${rifile}" "$SARA_ROOT/sara_ws/${rifile}"


## -------------------------------------------------------------
print_header "Updating repositories to use user's forks"
# Detect github username
github_info=$(ssh git@github.com 2>&1 | grep -G "Hi .*! You've successfully authenticated, but GitHub does not provide shell access.")
github_user=${github_info#Hi }
github_user=${github_user%%! You*}
if [ -z "$github_user" ]
then
    print_error "Your github username could not be identified."
    print_error "Your won't be able to access SARA packages. Aborting!"
    exit 1
fi
print_status "Your GitHub username has been identified as: $github_user"
#
use_personal_forks=""
if whiptail --yesno "Have you created your own forks of all SARA repositories for user $github_user?" 8 50
then
    print_status "Replacing generic branches with your own forks..."
    if [ "$github_user" == "pronobis" ]
    then
        print_status "Using the pronobis username quirk!"
        sed -i 's/master/pronobis/g' "$SARA_ROOT/sara_ws/${rifile}"
    else
        sed -i "s/pronobis/${github_user}/g" "$SARA_ROOT/sara_ws/${rifile}"
    fi
    use_personal_forks="1"
    print_status "Done!"
else
    whiptail --msgbox "You MUST have your own forks of SARA code if you plan to contribute to the system! If you choose not to fork the code DO NOT push anything to the master repositories! If you change your mind and make the forks, run this installation again!" 11 60
fi


## -------------------------------------------------------------
print_header "Installing SARA packages"
#
# MIRA configuration
if [ -f /opt/MIRA/scripts/mirabash ]
then
    print_status "Detected MIRA. Configuring MIRA environment..."
    export MIRA_PATH=/opt/MIRA:/opt/MIRA-commercial
    export LD_LIBRARY_PATH=/opt/MIRA/lib:${LD_LIBRARY_PATH}
    export PATH=/opt/MIRA/bin:${PATH}
    export MIRA_PATH=/opt/MIRA-commercial:${MIRA_PATH}
    export LD_LIBRARY_PATH=/opt/MIRA-commercial/lib:${LD_LIBRARY_PATH}
    source /opt/MIRA/scripts/mirabash
fi
#
if [ -f "$SARA_ROOT/sara_ws/src/.rosinstall" ]
then
    print_status "Existing installation exists. Updating..."
    rm "$SARA_ROOT/sara_ws/src/.rosinstall"
fi
#
print_status "\nInitializing workspace..."
mkdir -p "$SARA_ROOT/sara_ws/src"
cd "$SARA_ROOT/sara_ws"
wstool init -j4 "$SARA_ROOT/sara_ws/src" "$SARA_ROOT/sara_ws/${rifile}"
#
print_status "\nChecking for missing dependencies..."
source "$SARA_ROOT/rosjava_ws/devel/setup.bash"
# The following will result in an error about rosdep in utopic etc. so we add || true
rosdep install --from-paths src -i -y -r --os ubuntu:trusty || true
#
print_status "\nCompiling..."
catkin_make -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
# Done
print_status "Done!"


## -------------------------------------------------------------
source "$SARA_ROOT/sara_ws/devel/setup.bash"


## -------------------------------------------------------------
if [ -n "$use_personal_forks" ]
then
   print_header "Adding upstream remotes to the SARA repos"
   cd "$SARA_ROOT/sara_ws/src"
   rosrun sara_tools_git add_upstream
   # Done
   print_status "Done!"
fi


## -------------------------------------------------------------
## Finishing
## -------------------------------------------------------------
print_main_module_footer
unset DOT_MODULE_DIR
