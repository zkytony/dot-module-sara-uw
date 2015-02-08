# dot-module-sara
SARA Project dot files module.

## Installation
1. Install the dot package
2. Pull this module into DOT_DIR/modules
3. If you wish, you can now modify the path where sara stuff will be installed in `sara_root.conf`
4. If you have admin rights to this machine, run `install-sys.sh`
5. Run `install.sh`
7. In order to use EC2 API tools, you need to add your personal keys to your `~/.bashrc`:
```
export AWS_ACCESS_KEY=<access_key>
export AWS_SECRET_KEY=<secret_key>
```
