#!/bin/bash


# Constants
HardDisk="#HardDisk name" # Enter your Hard Disk name
Mount_Point="/media/#<Username>/$HardDisk" # Enter your username
Browse="#Folder" # Folder inside your hard disk to store the all the backup
DATE=$(date +"%d-%m-%Y")
Folder="#Folder name-$DATE" # Enter the folder name to save the file as
Address="#Username@#<IP Address>" # Enter the user name and the IP ADdress to connect to `username@IP Address`
Password="#Password" # Enter the password of the Server
Folder1="#Folder" # The folder where you want to download
Folder2="#Folder name" # The folder that you want to delete make sure that it is same as $Folder

# Function to check The hard disk is mounted
is_mounted() {
  mount | grep "$HardDisk" > /dev/null
  return $?
}

# Function to check if the hard disk is available
is_hard_disk_available() {
    lsblk | grep -i "$HardDisk" > /dev/null
    return $?
}

# Function to mount the hard disk
mount_hard_disk() {
    
    if is_hard_disk_available; then

        sudo mount /dev/sda2 "$Mount_Point"

        if [ $? -ne 0 ]; then
            echo -u critical Backup "Faild to mount $HardDisk Hard Disk to the system"
            exit 1
        fi

        echo -u critical Backup "Mounted $HardDisk successfully."

        main
    
    else

        echo -u critical Backup "The $HardDisk Hard Disk is not connected to the system"
        exit 1
    
    fi
}

# Function to delete older backup folders
delete_older_backups() {
    # Find all folders matching the pattern "<Folder>-DD-MM-YYYY"
    # that are older than 7 days and delete them
    find "$Mount_Point/$Browse/" -type d -name "$Folder2-*" -mtime +7 -exec rm -rf {} \;

    if [ $? -eq 0 ]; then
        echo "Older backup folders deleted successfully."
    else
        echo "Failed to delete older backup folders."
        echo -u critical Backup "Failed to delete older backup folders."
    fi
}

main() {

    if is_mounted; then

        cd "$Mount_Point/$Browse/" || {
            echo -u critical Backup "Failed to access directory: $Mount_Point/$Browse/"
            exit 1
        }

        mkdir -p "$Folder" || {
            echo -u critical Backup "Failed to create directory: $Folder"
            exit 1
        }

        sshpass -p "$Password" scp -r "$Address:$Folder1" "$Folder/" || {
            echo -u critical Backup "Failed to copy files from server."
            exit 1
        }

        echo -u critical Backup "Files copied successfully to $Folder."

        delete_older_backups

    else

        mount_hard_disk
    fi

}

main