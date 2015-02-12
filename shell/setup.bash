# -*- mode: sh -*-
## --------------------------------------------
## This file is executed for all bash sessions
## --------------------------------------------

# Load sara root from the config file in case the login shell was not yet re-run
eval "export SARA_ROOT=$(cat $DOT_MODULE_DIR/sara_root.conf)"

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

## ---------------------------
## Java settings
## ---------------------------
if [ -z "$JAVA_HOME" ]
then
    # Detect java, use oracle 7 first, then whatever the default is, and then try openjdk 1.7
    if [ -d /usr/lib/jvm/java-7-oracle ]
    then
        export JAVA_HOME="/usr/lib/jvm/java-7-oracle"
    elif [ -d /usr/lib/jvm/default-java ]
    then
        export JAVA_HOME="/usr/lib/jvm/default-java"
    elif [ -d /usr/lib/jvm/java-1.7.0-openjdk-amd64 ]
    then
        export JAVA_HOME="/usr/lib/jvm/java-1.7.0-openjdk-amd64"
    fi
fi
