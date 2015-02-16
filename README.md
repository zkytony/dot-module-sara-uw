# dot-module-sara
SARA Project dot files module.

## Installation

Please note that the steps marked with **[Single user setup only]** should only be performed on your local machine over which you have complete control. Do not perform those steps on SARA servers!

1. Install the main dot package:
    ```
git clone git@github.com:pronobis/dot.git ~/.dot
cd ~/.dot
./install.sh
    ```

2. **[Single user setup only]** If installing for the first time on a computer for which you have root access, run:
    ```
sudo -EH ./install.sh
    ```

3. Clone this package:
   ```
git clone --recursive git@github.com:pronobis/dot-module-sara-uw.git ~/.dot/modules/50_dot-module-sara-uw
cd ~/.dot/modules/50_dot-module-sara-uw
    ```

4. If you wish, you can now modify the path where sara stuff will be installed in `sara_root.conf`.

5. **[Single user setup only]** If installing for the first time on a computer for which you have root access, run:
    ```
sudo -EH ./install-sys.sh
    ```

6. Then, install user-local config. You may run into errors if your internet connection is bad. If you do, try running the command again.
    ```
./install.sh
    ```

7. In order to use EC2 API tools, you need to add your personal keys to your `~/.bashrc`:
    ```
export AWS_ACCESS_KEY=<access_key>
export AWS_SECRET_KEY=<secret_key>
    ```

8. Now, re-login and chose the system you want using the `sys` command.
