# -*- mode: sh -*-
## --------------------------------------------
## This file is executed for all bash sessions
## --------------------------------------------

## ---------------------------
## Add private key to SSH Agent
## to be served to other machines we SSH to
## ---------------------------
ssh-add ~/.ssh/id_rsa 2&> /dev/null

## ---------------------------
## Amazon EC2 Settings
## ---------------------------
# Paths
export EC2_HOME=${DOT_MODULE_DIR}/opt/ec2-api-tools
export PATH=$PATH:${DOT_MODULE_DIR}/opt/ec2-api-tools/bin
# URL
export EC2_URL=https://ec2.us-west-2.amazonaws.com
# Aliases
alias ec2-status="ec2-describe-instance-status -AH | awk '{print \$2 \"\\t\" \$4}'"
