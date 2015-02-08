# -*- mode: sh -*-
## --------------------------------------------
## This file is executed for all bash sessions
## --------------------------------------------

## ---------------------------
## Add private key to SSH Agent
## to be served to other machines we SSH to
## ---------------------------
ssh-add ~/.ssh/id_rsa 2&> /dev/null
