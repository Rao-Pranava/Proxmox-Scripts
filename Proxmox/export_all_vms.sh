#!/bin/bash

# Timestamp and backup dir
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
BACKUP_DIR="/backups/vm_export_$TIMESTAMP"
mkdir -p "$BACKUP_DIR"

cd /home || exit 1

# Get list of powered-off VMs
POWERED_OFF_VMS=$(qm list | awk '$3 == "stopped" {print $2}')

if [ -z "$POWERED_OFF_VMS" ]; then
    echo "No VMs are powered off. Nothing to backup."
    exit 0
fi

echo "Starting backup for powered-off VMs..."
echo "$POWERED_OFF_VMS" | while read -r VM_NAME; do
    echo "Backing up: $VM_NAME"

    # Run the Proxmox.sh export
    bash ./Proxmox.sh --export --name "$VM_NAME" --format qcow2

    # Wait until the file is available and stable
    while true; do
        FILE="/home/${VM_NAME}.qcow2"
        if [ -f "$FILE" ]; then
            lsof "$FILE" &>/dev/null
            if [ $? -ne 0 ]; then
                break
            fi
        fi
        sleep 5
    done

    # Move the backup to backup dir
    mv "/home/${VM_NAME}.qcow2" "$BACKUP_DIR/"
    echo "Backup complete: $VM_NAME"
done

# Zip the entire backup folder
cd /backups || exit 1
tar -czvf "vm_exports_$TIMESTAMP.tar.gz" "vm_export_$TIMESTAMP"
rm -rf "vm_export_$TIMESTAMP"

echo "All exports complete. Zipped and cleaned up."
