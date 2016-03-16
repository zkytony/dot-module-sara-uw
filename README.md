# dot-module-sara
SARA Project dot module.

## Pre-Install notes

Installation has been tested for Ubuntu 14.04.1 and 15.10. There are known dependency issues for Ubuntu 14.04.2 involving `libcheese`.

## Installation

1. Install the [main dot package](https://github.com/pronobis/dot):
    ```
    git clone https://github.com/pronobis/dot.git ~/.dot; ~/.dot/install.sh
    ```

2. Re-login

3. Download this module:
    ```
    dot-get add git@github.com:pronobis/dot-module-sara-uw.git
    ```

4. If you wish, you can now modify the path where sara stuff will be installed in `sara_root.conf`

5. Install this module:
    ```
    cd ~/.dot/modules/50_dot-module-sara-uw; ./install.sh
    ```

6. In order to use EC2 API tools, you need to add your personal keys to your `~/.bashrc`:
    ```
export AWS_ACCESS_KEY=<access_key>
export AWS_SECRET_KEY=<secret_key>
    ```

7. Now, re-login and choose the system you want using the `sys` command
