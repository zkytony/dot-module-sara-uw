#!/bin/bash

dot_shell=$(cd "${0%/*}/../../shell" && pwd); . "$dot_shell/install_module_header.sh"
dot_check_root # Check if we run as root
dot_check_ubuntu  # Are we on Ubuntu?
dot_check_virtualenv  # Check for virtualenv


## -------------------------------------------------------------
## Installation
## -------------------------------------------------------------

## -------------------------------------------------------------
# Load sara root from the config file in case the login shell was not yet re-run
eval "export SARA_ROOT=$(cat $DOT_MODULE_DIR/sara_root.conf)"
print_info "SARA_ROOT is set to: ${SARA_ROOT}"


## -------------------------------------------------------------
print_header "Installing user-local config files"
# VNC client
dot_link_config ".vnc/profiles/sara_uw_dube.vnc"
dot_link_config ".vnc/profiles/sara_uw_ec2_sim.vnc"
# Shortcuts
dot_link_config ".local/share/applications/*.desktop"
# SSH
dot_prepend_section_to_config ".ssh/config" "# dot-module-sara-uw configuration begins here" "# dot-module-sara-uw configuration ends here"
# Art
dot_link_config ".local/share/icons/*.png"
dot_link_config ".local/share/wallpapers/*.png"
# Done
print_status "Done!"


## -------------------------------------------------------------
print_header "Verifying GitHub access"
# Detect github username
github_info=$(ssh git@github.com 2>&1 | grep -G "Hi .*! You've successfully authenticated, but GitHub does not provide shell access." || true)
github_user=${github_info#Hi }
github_user=${github_user%%! You*}
if [ -z "$github_user" ]
then
    print_warning "Could not connect to GitHub."
    print_warning "GitHub access is most likely not configured on this machine."
    print_warning "Make sure the SSH key is added to GitHub settings or use SSH agent forwarding."
    print_error "Your won't be able to access SARA packages. Aborting!"
    exit 1
fi
print_status "GitHub access configured properly."
print_status "Your GitHub username has been identified as: $github_user"


## -------------------------------------------------------------
print_header "Installing required Ubuntu system packages"
# software-properties-common - for apt-add-repository
if dot_check_packages build-essential ccache cmake python-setuptools python3-setuptools whiptail software-properties-common
then
    print_status "All required Ubuntu system packages are already installed."
else
    dot_install_packages $DOT_NOT_INSTALLED
    print_status "Done!"
fi


## -------------------------------------------------------------
# Missing packages are installed from source in 15.04
print_header "Installing required source packages"
if dot_is_min_ubuntu_version 15.10 && dot_is_max_ubuntu_version 15.10
then
    print_warning "You are running Ubuntu >=15.10."
    print_warning "Some ROS dependencies (collada-dom, PCL) must be installed from source."
    if [ -f /usr/lib/libcollada-dom*-dp.so ]
    then
        print_status "collada-dom is already installed."
    else
        if yes_no_question "Install collada-dom (master branch) from source system-wide?"
        then
            print_status "Installing collada-dom Ubuntu dependencies..."
            if dot_check_packages build-essential libboost-dev libboost-filesystem-dev libboost-system-dev
            then
                print_status "All Ubuntu dependencies are already installed."
            else
                dot_install_packages $DOT_NOT_INSTALLED
                print_status "Done!"
            fi
            print_status "Downloading collada-dom (master branch)..."
            dot_git_clone_or_update "${TMP_DIR}/collada-dom" "https://github.com/rdiankov/collada-dom.git" "master"
            print_status "Compiling collada-dom..."
            cd "${TMP_DIR}/collada-dom"
            mkdir -p build
            cd build
            cmake .. -DCMAKE_INSTALL_PREFIX:PATH=/usr
            dot_parallel_make
            print_status "Installing collada-dom..."
            sudo make install
        fi
    fi
    if [ -f /usr/local/lib/libpcl_features.so ] || [ -f /usr/lib/x86_64-linux-gnu/libpcl_features.so.1.7 ]
    then
        print_status "PCL is already installed."
    else
        if yes_no_question "Install PCL (master branch) from source system-wide?"
        then
            print_status "Installing PCL Ubuntu dependencies..."
            if dot_check_packages libflann-dev libvtk5-dev libvtk-java python-vtk libvtk5-qt4-dev libboost-dev libboost-thread-dev libboost-date-time-dev libboost-iostreams-dev libeigen3-dev
            then
                print_status "All Ubuntu dependencies are already installed."
            else
                dot_install_packages $DOT_NOT_INSTALLED
                print_status "Done!"
            fi
            print_status "Downloading PCL (master branch)..."
            dot_git_clone_or_update "${TMP_DIR}/pcl" "https://github.com/PointCloudLibrary/pcl.git" "master"
            print_status "Compiling PCL..."
            cd "${TMP_DIR}/pcl"
            mkdir -p build
            cd build
            # Install to /usr/local
            cmake .. -DBUILD_apps=ON -DPCL_QT_VERSION=4
            dot_parallel_make
            print_status "Installing PCL..."
            sudo make install
        fi
    fi
else
    print_status "You are NOT running Ubuntu 15.10."
    print_status "All ROS dependencies are available as packages."
fi


## -------------------------------------------------------------
print_header "Installing ROS"
if dot_is_ubuntu_codename "trusty"
then
    print_status "You are running Ubuntu 14.04 Trusty."
    print_status "ROS Ubuntu packages will be used.\n"
    #
    if dot_get_installed_package_version ros-indigo-catkin ros-indigo-ros python-wstool
    then
        print_status "ROS Ubuntu packages are already installed."
    else
        if yes_no_question "Install ROS Ubuntu packages?"
        then
            print_status "Adding ROS repositories..."
            sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu trusty main" > /etc/apt/sources.list.d/ros-latest.list'
            sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net --recv-key 0xB01FA116
            sudo apt-get update
            #
            print_status "Installing ROS packages..."
            sudo apt-get install ros-indigo-catkin ros-indigo-ros python-wstool
            #
            print_status "Updating rosdep..."
            sudo rosdep init > /dev/null || true  # Will fail if already inited
            rosdep update
            # Done!
            print_status "Done!"
        fi
    fi
else
    print_warning "You are not running Ubuntu 14.04 Trusty."
    print_warning "ROS must be installed from sources.\n"
    if yes_no_question "(Re-)Install ROS from sources?"
    then
        # Fixes for 16.04
        if dot_is_min_ubuntu_version 16.04
        then
            # The VTK6 in 16.04 as of version 6.2.0+dfsg1-10build1 is buggy:
            # https://bugs.launchpad.net/ubuntu/+source/vtk6/+bug/1573234
            # There is a fix in a PPA until that is fixed
            print_status "Installing fixed VTK6 from PPA..."
            sudo apt-add-repository ppa:tully.foote/backports
            # Force-update package list
            DOT_MODULE_PACKAGES_UPDATED=""
            # Install the packages
            dot_install_packages libvtk6-dev vtk6
            # Some packages have different names in 16.04 and won't
            # be installed by rosdep
            print_status "Installing Ubuntu dependencies..."
            if dot_check_packages libogre-1.9-dev python-wxgtk3.0 libcollada-dom2.4-dp-dev libpcl-dev libproj-dev
            then
                print_status "All required Ubuntu dependencies are already installed."
            else
                dot_install_packages $DOT_NOT_INSTALLED
                print_status "Done!"
            fi
        fi
        # rosdep
        print_status "Installing rosdep and wstool..."
        sudo pip install -U rosdep rosinstall_generator wstool rosinstall
        print_status "Updating rosdep..."
        sudo rosdep init > /dev/null || true  # Will fail if already inited
        rosdep update
        # ROS
        print_status "Installing ROS from sources..."
        if [ -f "$SARA_ROOT/ros_ws/src/.rosinstall" ]
        then
            print_status "Existing ROS source installation exists. Updating..."
            rm "$SARA_ROOT/ros_ws/src/.rosinstall"
        fi
        print_status "Initializing workspace..."
        mkdir -p "$SARA_ROOT/ros_ws/src"
        cd "$SARA_ROOT/ros_ws"
        rosinstall_generator desktop perception navigation slam_gmapping audio_common openni2_launch robot_pose_publisher dynamixel_motor depthimage_to_laserscan yujin_ocs kobuki usb_cam rosbridge_suite openni_launch prosilica_camera hokuyo_node joystick_drivers robot_localization octomap_ros octomap octomap_mapping octomap_rviz_plugins octomap_msgs teb_local_planner --rosdistro indigo --deps --wet-only --tar > "$SARA_ROOT/ros_ws/sara_ros.rosinstall"
        # The true is needed in order to pass through an error that might happen when the tar package
        # versions are updated. Then wstool update will deal with that problem.
        # Those errors are normal and should be ignored.
        print_info "Any error below is OK:"
        wstool init -j4 "$SARA_ROOT/ros_ws/src" "$SARA_ROOT/ros_ws/sara_ros.rosinstall" || true
        # We need to update octomap_rviz_plugins to indigo-devel due to a bug
        # that is not fixed in the .tar package. Once this commit gets to the package
        # https://github.com/OctoMap/octomap_rviz_plugins/commit/b4a5d30ac6178fbeba5020969783dfb9bf4fcdc3
        # we can just skip this step.
        wstool set octomap_rviz_plugins -y --version-new indigo-devel --git https://github.com/OctoMap/octomap_rviz_plugins.git -t "$SARA_ROOT/ros_ws/src"
        # libg2o indigo version fails to compile on 16.04, but the kinetic version compiles
        # libg2o is only needed by teb_local_planner
        wstool set libg2o -y --version-new libg2o-release-release-kinetic-libg2o-2016.4.24-0 https://github.com/ros-gbp/libg2o-release/archive/release/kinetic/libg2o/2016.4.24-0.tar.gz -t "$SARA_ROOT/ros_ws/src"
        # Now, update
        wstool update --delete-changed-uris -t "$SARA_ROOT/ros_ws/src"
        #
        print_status "Checking for missing dependencies..."
        # On 16.04 this will install python-vtk which will remove libpcl
        # python-vtk6 is installed by libpcl-dev instead on 16.04
        if dot_is_min_ubuntu_version 16.04
        then
            # The following will result in an error about rosdep in non-trusty etc. so we add || true
            rosdep install --from-paths src -y -i -r --skip-keys=python-vtk --os ubuntu:trusty || true
        else
            # The following will result in an error about rosdep in non-trusty etc. so we add || true
            rosdep install --from-paths src -y -i -r --os ubuntu:trusty || true
        fi
        #
        print_status "Compiling..."
        # Use a clean environment to not have any dependencies
        # Run with -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
        env -i HOME=$HOME PATH="/usr/bin:/bin" bash -c "source /etc/profile; ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
        # Repeat without -DCMAKE_EXPORT_COMPILE_COMMANDS=ON since rosjava doesn't like it.
        env -i HOME=$HOME PATH="/usr/bin:/bin" bash -c "source /etc/profile; ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release"
        # Done
        print_status "Done!"
    fi
fi


## -------------------------------------------------------------
# Currently we don't have any custom package versions to install
# since all the changes have been merged upstream.
# If you uncomment the code below, don't forget to change the sourced paths!

# print_header "Installing custom ROS packages"
# if yes_no_question "(Re-)Install custom ROS packages?"
# then
#     if [ -f "$SARA_ROOT/ros_custom_ws/src/.rosinstall" ]
#     then
#         print_status "Existing installation exists. Updating..."
#         rm "$SARA_ROOT/ros_custom_ws/src/.rosinstall"
#     fi
#     print_status "Initializing workspace..."
#     mkdir -p "$SARA_ROOT/ros_custom_ws/src"
#     cd "$SARA_ROOT/ros_custom_ws"
#     # The true is needed in order to pass through an error that might happen when the tar package
#     # versions are updated. Then wstool update will deal with that problem.
#     wstool init -j4 "$SARA_ROOT/ros_custom_ws/src" "$DOT_MODULE_DIR/rosinstall/sara_ros_custom.rosinstall" || true
#     wstool update --delete-changed-uris -t "$SARA_ROOT/ros_custom_ws/src"
#     print_status "Checking for missing dependencies..."
#     if [ -f /opt/ros/indigo/setup.bash ]
#     then
#         source /opt/ros/indigo/setup.bash
#     else
#         source "$SARA_ROOT/ros_ws/install_isolated/setup.bash"
#     fi
#     # The following will result in an error about rosdep in utopic etc. so we add || true
#     rosdep install --from-paths src -i -y -r --os ubuntu:trusty || true
#     print_status "Compiling..."
#     # With -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
#     catkin_make -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
#     # Repeat without -DCMAKE_EXPORT_COMPILE_COMMANDS=ON since rosjava doesn't like it
#     catkin_make -DCMAKE_BUILD_TYPE=Release
#     # Done
#     print_status "Done!"
# fi


## -------------------------------------------------------------
print_header "Installing ROSJava packages"
ROSJAVA_INSTALLED=""
if yes_no_question "(Re-)Install ROS Java (from sources)?"
then
    if [ -f "$SARA_ROOT/rosjava_ws/src/.rosinstall" ]
    then
        print_status "Existing installation exists. Updating..."
        rm "$SARA_ROOT/rosjava_ws/src/.rosinstall"
    fi
    #
    print_status "Initializing workspace..."
    mkdir -p "$SARA_ROOT/rosjava_ws/src"
    cd "$SARA_ROOT/rosjava_ws"
    # The true is needed in order to pass through an error that might happen when the tar package
    # versions are updated. Then wstool update will deal with that problem.
    wstool init -j4 "$SARA_ROOT/rosjava_ws/src" "$DOT_MODULE_DIR/rosinstall/sara_rosjava.rosinstall" || true
    wstool update --delete-changed-uris -t "$SARA_ROOT/rosjava_ws/src"
    #
    print_status "Checking for missing dependencies..."
    if [ -f /opt/ros/indigo/setup.bash ]
    then
        source /opt/ros/indigo/setup.bash
    else
        source "$SARA_ROOT/ros_ws/install_isolated/setup.bash"
    fi
    # The following will result in an error about rosdep in utopic etc. so we add || true
    rosdep install --from-paths src -i -y -r --os ubuntu:trusty || true
    #
    print_status "Compiling..."
    # Clean any MAVEN environment variable that might be set
    unset ROS_MAVEN_DEPLOYMENT_REPOSITORY
    unset ROS_MAVEN_PATH
    unset ROS_MAVEN_REPOSITORY
    catkin_make -DCMAKE_BUILD_TYPE=Release
    # Done
    ROSJAVA_INSTALLED=1
    print_status "Done!"
fi


## -------------------------------------------------------------
print_header "Installing Blender"
BLENDER_INSTALLED=""
INSTALL_BLENDER=""
MIN_BLENDER_VERSION="2.77"
# Check
if dot_get_installed_package_version blender
then
    if dot_versions_ge $DOT_PACKAGE_VERSION $MIN_BLENDER_VERSION
    then
        print_status "Blender $DOT_PACKAGE_VERSION is already installed."
        BLENDER_INSTALLED=1
    else
        print_warning "Blender is installed, but version is <= ${MIN_BLENDER_VERSION}. Recent Blender version is needed for the Morse simulator."
        if yes_no_question "Update Blender to >= $MIN_BLENDER_VERSION?"
        then
            INSTALL_BLENDER=1
        fi
    fi
else
    print_warning "Blender is NOT installed. Recent Blender version is needed for the Morse simulator."
    print_warning "NOTE: Blender and Morse are NOT needed on robots!"
    if yes_no_question "Install Blender >= $MIN_BLENDER_VERSION?"
    then
        INSTALL_BLENDER=1
    fi
fi
# Install
if [ -n "$INSTALL_BLENDER" ]
then
    # Add PPA
    print_status "Adding PPA..."
    sudo apt-add-repository -y ppa:thomas-schiex/blender
    print_status "Installing package..."
    # Force-update package list
    DOT_MODULE_PACKAGES_UPDATED=""
    # Install the packages
    dot_install_packages blender python3-numpy
    # Done
    BLENDER_INSTALLED=1
    print_status "Done!"
fi


## -------------------------------------------------------------
print_header "Installing Morse"
MORSE_DIR="${DOT_MODULE_DIR}/opt/morse"
# Check whether to install
INSTALL_MORSE=""
if [ -n "$BLENDER_INSTALLED" ]
then
    if [ -d "$MORSE_DIR" ]
    then
        # Check if morse binary exists.
        if [ ! -f "${MORSE_DIR}/bin/morse" ]
        then
            print_warning "Previous Morse installation corrupted."
        else
            print_status "Morse is already installed."
        fi

        if yes_no_question "Re-install Morse (WARNING: this will remove ${MORSE_DIR} and $HOME/.virtualenv/sara_morse)?"
        then
            print_info "Removing ${MORSE_DIR}."
            rm -rf $MORSE_DIR
            rm -rf $HOME/.virtualenv/sara_morse
            INSTALL_MORSE=1
        fi
    else
        if yes_no_question "Install Morse?"
        then
            INSTALL_MORSE=1
        fi
    fi
else
    print_warning "Blender >= $MIN_BLENDER_VERSION is not installed, skipping Morse installation."
fi
# Install
if [ -n "$INSTALL_MORSE" ]
then
    print_status "Installing Morse Ubuntu dependencies..."
    # python3.5 - the new Blender in PPA is using Python 3.5 and we need to match
    #             the same version in Morse
    package_list="cmake git zlib1g-dev libyaml-dev blender python3-dev python3-pip libpython3-dev python3-setuptools python3-yaml python3-netifaces python3-setuptools python3-pip python3-dev python3-numpy python3.5 python3.5-dev"
    # Version dependent packages
    if dot_is_min_ubuntu_version 14.10
    then
        package_list="${package_list} virtualenv python3-virtualenv"
    else
        package_list="${package_list} python-virtualenv"
    fi
    if dot_check_packages $package_list
    then
        print_status "All Ubuntu dependencies are already installed."
    else
        dot_install_packages $DOT_NOT_INSTALLED
        print_status "Done!"
    fi
    print_status "Installing basic ROS packages in a virtualenv for Python 3..."
    mkdir -p "$HOME/.virtualenv"
    cd "$HOME/.virtualenv"
    # Allow the vitual environments to use the system-wide packages
    # Use Python 3.5 since that is what is used by the new Blender from PPA
    virtualenv sara_morse -p /usr/bin/python3.5 --system-site-packages
    . "$HOME/.virtualenv/sara_morse/bin/activate"
    dot_install_pip3 rosdep
    dot_install_pip3 rosinstall_generator
    dot_install_pip3 wstool
    dot_install_pip3 rosinstall
    print_status "Downloading Morse..."
    dot_git_clone_or_update "${TMP_DIR}/morse" "https://github.com/pronobis/morse.git" "master"
    print_status "Installing Morse..."
    cd "${TMP_DIR}/morse"
    mkdir -p build
    cd build
    cmake -DCMAKE_INSTALL_PREFIX=${MORSE_DIR} -DPYMORSE_SUPPORT=ON -DBUILD_ROS_SUPPORT=ON -DCMAKE_BUILD_TYPE=Release ..
    make install
    print_status "Checking MORSE installation..."
    export PATH="${DOT_MODULE_DIR}/opt/morse/bin:$PATH"
    export PYTHONPATH="${DOT_MODULE_DIR}/opt/morse/lib/python3/dist-packages:$PYTHONPATH"
    $MORSE_DIR/bin/morse check
    # Deactivate the virtualenv
    deactivate
    # Done
    print_status "Done!"
fi


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
rifile=$(whiptail --title "Select SARA System Setup" --menu "" 20 50 10 ${configs} 3>&2 2>&1 1>&3 || true)
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
print_status "Your GitHub username has been identified as: $github_user"
use_personal_forks=""
if yes_no_question "Have you created your own forks of all SARA repositories for user $github_user?"
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
    export MIRA_PATH=/opt/MIRA
    export LD_LIBRARY_PATH=/opt/MIRA/lib:${LD_LIBRARY_PATH}
    export PATH=/opt/MIRA/bin:${PATH}
    export MIRA_PATH=/opt/MIRA-commercial:${MIRA_PATH}
    export LD_LIBRARY_PATH=/opt/MIRA-commercial/lib:${LD_LIBRARY_PATH}
    export MIRA_PATH=${SARA_ROOT}/sara_ws/src:${MIRA_PATH}
    source /opt/MIRA/scripts/mirabash
fi
#
if [ -f "$SARA_ROOT/sara_ws/src/.rosinstall" ]
then
    print_status "Existing installation exists. Updating..."
    rm "$SARA_ROOT/sara_ws/src/.rosinstall"
fi
#
print_status "Initializing workspace..."
mkdir -p "$SARA_ROOT/sara_ws/src"
cd "$SARA_ROOT/sara_ws"
wstool init -j4 "$SARA_ROOT/sara_ws/src" "$SARA_ROOT/sara_ws/${rifile}"
#
print_status "Checking for missing dependencies..."
if [ -n "$ROSJAVA_INSTALLED" ]
then
    source "$SARA_ROOT/rosjava_ws/devel/setup.bash"
else
    if [ -f /opt/ros/indigo/setup.bash ]
    then
        source /opt/ros/indigo/setup.bash
    else
        source "$SARA_ROOT/ros_ws/install_isolated/setup.bash"
    fi
fi
# The following will result in an error about rosdep in utopic etc. so we add || true
rosdep install --from-paths src -i -y -r --os ubuntu:trusty || true
#
print_status "Compiling..."
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
print_header "Installing EC2 API tools"
print_status "Downloading..."
cd ${TMP_DIR}
rm -rf ec2-api-tools.zip
wget http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip
print_status "Obtaining version..."
ec2_ver=$(unzip -v ec2-api-tools.zip | grep -G "ec2-api-tools-[0-9\.]*/$")
ec2_ver=${ec2_ver##*ec2-api-tools-}
ec2_ver=${ec2_ver%%/*}
print_status "Installing verision $ec2_ver..."
rm -rf ec2-api-tools-$ec2_ver
unzip -q ec2-api-tools.zip
rm -rf "${DOT_MODULE_DIR}/opt/ec2-api-tools"
mv ec2-api-tools-$ec2_ver "${DOT_MODULE_DIR}/opt/ec2-api-tools"
print_status "Done!"


## -------------------------------------------------------------
## Done!
## -------------------------------------------------------------
. "$dot_shell/install_module_footer.sh"
