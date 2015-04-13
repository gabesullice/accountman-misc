#!/bin/sh

# CONFIGURATION

# This is the key file used by sshd to allow server access
authorized_keys_file=$HOME/.ssh/authorized_keys

# This file must be present on the system to help ensure that there is always
# at least one key in the authorized_keys file
#
# This file can contain any number of keys. EACH key must contain the comment:
#
#     accountman-id=DEFAULT
# 
# Without this, this script will keep adding new copies of these default keys
# ad infinitum.
#
# Example contents:
#
# command="some command" ssh-rsa =sshkey== user@email.com some comments accountman-id=DEFAULT
# ssh-rsa =sshkey== user2@email.com this is another key accountman-id=DEFAULT
#
default_keys=$HOME/.ssh/authorized_keys_default

# DO NOT EDIT BELOW THIS LINE

# Ensure the authorized_keys file is present
if [ ! -f $authorized_keys_file ]; then
  return 1
fi

# Ensure the default_keys file is present
if [ ! -f $default_keys ]; then
  return 2
fi

# Local Variables
operation=$1
key=${@:2}
id=$(echo "$key" | sed 's/.* accountman-id=\([^ ]*\) .*/\1/g')

# Either add, replace, or remove a key depending on the command operation
case $operation in
  "PUT")
    # Append the given key to the authorized_keys file
    echo $key >> $authorized_keys_file
    ;;
  "PATCH")
    # Replace the key mathcing the given keys id in the authorized_keys file
    sed -i.bak "/.* accountman-id=$id\( .*\)\?\$/c$key" $authorized_keys_file
    ;;
  "DELETE")
    # Delete the key mathcing the given from in the authorized_keys file
    sed -i.bak "/.* accountman-id=$id\( .*\)\?\$/d" $authorized_keys_file
    ;;
esac

# Ensure backup access method is present
# First remove previous default key
sed -i.bak "/.* accountman-id=DEFAULT\( .*\)\?\$/d" $authorized_keys_file

# Add the default key as provided to the authorized_keys file
cat $default_keys >> $authorized_keys_file
