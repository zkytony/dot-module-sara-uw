# dot-module-sara
SARA Project dot module.

## Pre-Install notes

Installation has been tested for Ubuntu 14.04.3 and 15.10. There are known dependency issues for Ubuntu 14.04.2 involving `libcheese`.

## Installation

Before you begin the installation, if you are planning to develop your own code at any time in the future, create your own forks of all the SARA repos you were given access to. The installer will setup these forks for you automatically.

1. Make sure `git` is installed on your system

2. Make sure that you have access to the SARA git repositories from the system you are running the installer on.

3. Install the [main dot package](https://github.com/pronobis/dot):
    ```
    git clone https://github.com/pronobis/dot.git ~/.dot; ~/.dot/install.sh
    ```

4. Re-login

5. Download this module:
    ```
    dot-get add git@github.com:pronobis/dot-module-sara-uw.git
    ```

6. If you wish, you can now modify the path where sara stuff will be installed in `sara_root.conf`

7. Install this module:
    ```
    cd ~/.dot/modules/50_dot-module-sara-uw; ./install.sh
    ```
    During the installation, you will be asked several questions. Follow these instructions:
    - Do not install ROS Java, unless explicitly instructed to do so.
    - When asked, choose the appropriate SARA system setup. If you are installing on a desktop machine, choose `sara_uw_desktop.rosinstall` (choose this if unsure). If you are installing on an Amazon EC2 machine, choose `sara_uw_ec2.rosinstall`. If you are installing ON THE ROBOT itself, choose `sara_uw_robot.rosinstall`.
    - If you have your own forks of the SARA repos, make sure to answer Yes to the question "Have you created your own forks of all SARA repositories for user \<your-github-username>?"

8. In order to use EC2 API tools, you need to add your personal keys to your `~/.bashrc`:
    ```
export AWS_ACCESS_KEY=<access_key>
export AWS_SECRET_KEY=<secret_key>
    ```

9. Re-login

10. Choose the system configuration that you plan to use with the `sys` command. Choose 'SARA Local' if you are running the system on your machine only. Choose `SARA UW Master Robot` if you are running the system on both the robot and your local machine and the robot is the master. Choose `SARA UW DUB-E Setup` if you are running the system directly on the robot.

11. Test the installation by running:
    * Morse simulator in one console: `roslaunch sara_uw_morse simple.launch`
    * RViz in another console: `roslaunch sara_uw_visualization robot.launch`

    The simulator and RViz should start. Once the simulator starts (can take a while), you should be able to control the robot in the simulator with the arrow keys and see the corresponding sensory input in RViz.
