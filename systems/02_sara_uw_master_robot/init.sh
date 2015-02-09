#!/bin/bash

. $DOT_DIR/shell/tools.bash

print_status "Restarting OpenVPN"
sudo /etc/init.d/openvpn restart
print_status "Done"
