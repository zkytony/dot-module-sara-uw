# -*- mode: sh -*-
## --------------------------------------------
## This file is executed for all bash sessions
## --------------------------------------------

# Include formatting
. "$DOT_DIR/shell/formatting.sh"

# Load sara root from the config file in case the login shell was not yet re-run
eval "export SARA_ROOT=$(cat $DOT_MODULE_DIR/sara_root.conf)"

## ---------------------------
## Add private key to SSH Agent
## to be served to other machines we SSH to
## ---------------------------
ssh-add ~/.ssh/id_rsa 2&> /dev/null

## ---------------------------
## Aliases
## ---------------------------
alias sara="cd $SARA_ROOT/sara_ws/src"
if [ -f /opt/ros/indigo/setup.bash ]
then
    alias ros="cd /opt/ros/indigo"
else
    alias ros="cd $SARA_ROOT/ros_ws/src"
fi


## ---------------------------
## Amazon EC2 Settings
## ---------------------------
# Paths
export EC2_HOME=${DOT_MODULE_DIR}/opt/ec2-api-tools
# URL
export EC2_URL=https://ec2.us-west-2.amazonaws.com
# Get status
function ec2-status
{
    info=$( ec2-describe-instances --show-empty-fields )
    sedcmd=""
    old_IFS=$IFS; IFS=$'\n'
    for i in $( echo "$info" | grep TAG | grep Name )
    do
        id=$( echo $i | sed 's/\(.*instance[ \t]*\)\([^ \t]*\)\([ \t]*.*\)/\2/' )
        name=$( echo $i | sed 's/\(.*Name[ \t]*\)\(.*\)/\2/' )
        name=$( printf "%-20s" "$name" )
        sedcmd="$sedcmd -e 's/\($id\)/\1 | $name/'"
    done
    IFS=$old_IFS
    all=$( echo "$info" | grep INSTANCE | awk '{print $2 " | " $6}' | eval "sed $sedcmd" )

    set_format ${LIGHT_GREEN}
    echo "Running instances:"
    clear_format
    echo "$all" | grep --color=never running
    echo
    set_format ${LIGHT_GREEN}
    echo "Other instances:"
    clear_format
    echo "$all" | grep -v --color=never running
}


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
