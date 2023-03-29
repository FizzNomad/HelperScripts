#!/bin/bash

# Function to validate user input
validate_input() {
    local option_name=$1
    local option_value=$2

    case $option_name in
        directory_path)
            if [[ ! -d $option_value ]]; then
                echo "Directory does not exist: $option_value"
                exit 1
            fi
            ;;
        hostname)
            if [[ -z $option_value ]]; then
                echo "Hostname cannot be empty."
                exit 1
            fi
            ;;
        permissions)
            local permissions=($(echo "$option_value" | tr ',' ' '))
            local valid_permissions=("rw" "ro" "no_root_squash" "root_squash" "sync" "async")
            for permission in "${permissions[@]}"; do
                if [[ ! "${valid_permissions[@]}" =~ "${permission}" ]]; then
                    echo "Invalid permissions value: $permission"
                    echo "Valid values are: rw, ro, no_root_squash, root_squash, sync, async"
                    exit 1
                fi
            done
            ;;
    esac
}


# Prompt the user for input
while true; do
    read -p "Enter directory path to create: " DIRECTORY_PATH
    if [[ -d $DIRECTORY_PATH ]]; then
        read -p "Directory already exists. Do you want to use this directory (Y/n)? " USE_EXISTING_DIR
        if [[ $USE_EXISTING_DIR == "Y" || $USE_EXISTING_DIR == "y" || $USE_EXISTING_DIR == "" ]]; then
            break
        fi
    else
        mkdir -p $DIRECTORY_PATH
        break
    fi
done


read -p "Enter hostname to allow access (wildcards allowed): " HOSTNAME
validate_input "hostname" "$HOSTNAME"

valid_permissions=("rw" "ro" "no_root_squash" "root_squash" "sync" "async")

echo "Valid permissions:"
for i in "${!valid_permissions[@]}"; do
    echo "$((i+1)): ${valid_permissions[i]}"
done

while true; do
    read -p "Enter permission to apply (1-6): " PERMISSION_INDEX
    if ! [[ "$PERMISSION_INDEX" =~ ^[1-6]$ ]]; then
        echo "Invalid input. Please enter a number between 1-6."
        continue
    fi
    PERMISSIONS_LIST+=(${valid_permissions[$((PERMISSION_INDEX-1))]})
    read -p "Add another permission (y/n)? " ADD_ANOTHER
    if [[ $ADD_ANOTHER == "n" ]]; then
        break
    fi
done

# Combine permissions into comma-separated string
PERMISSIONS=$(IFS=','; echo "${PERMISSIONS_LIST[*]}")

# Create the NFS export entry
NFS_ENTRY="$DIRECTORY_PATH $HOSTNAME($PERMISSIONS)"

# Add the entry to the exports file
echo "$NFS_ENTRY" | sudo tee -a /etc/exports > /dev/null

echo "NFS export successfully created:"
echo "$NFS_ENTRY"
# Reload the NFS service
sudo systemctl reload nfs-server
