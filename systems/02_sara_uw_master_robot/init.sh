#!/bin/bash

. $DOT_DIR/shell/tools.sh

print_status "Restarting OpenVPN"
sudo /etc/init.d/openvpn restart
