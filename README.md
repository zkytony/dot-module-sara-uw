# dot-module-sara
SARA Project dot files module.

## Installation

Install the main dot package:
```
git clone https://github.com/pronobis/dot.git ~/.dot
cd ~/.dot
./install.sh
```

If installing for the first time on a computer for which you have root access, run:
```
sudo -EH ./install.sh
```

Clone this package:
```
git clone git@github.com:pronobis/dot-module-sara-uw.git ~/.dot/modules/50_dot-module-sara-uw
cd ~/.dot/modules/50_dot-module-sara-uw
```

If you wish, you can now modify the path where sara stuff will be installed in `sara_root.conf`.

If installing for the first time on a computer for which you have root access, run:
```
sudo -EH ./install.sh
```

Then, install user-local config:
```
./install.sh
```

In order to use EC2 API tools, you need to add your personal keys to your `~/.bashrc`:
```
export AWS_ACCESS_KEY=<access_key>
export AWS_SECRET_KEY=<secret_key>
```
