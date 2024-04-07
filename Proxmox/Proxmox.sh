#!/bin/bash

# Global variables
Import=0

# Defining funtions

# Fuction to slow type
slow_type() {
    local text="$1"
    local delay=0.03

    for ((i = 0; i < ${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep $delay
    done
    echo
}

# Function to check if the virtual machine exists
check_vm_exists() {
    
    local vm_name="$1"
    local vm_list=$(qm list | awk '{print $2}')

    for vm in $vm_list; do
        if [ "$vm" == "$vm_name" ]; then
            return 0
        fi
    done

    return 1
}

create_vm() {

    slow_type "Enter the name for the new virtual machine: "
    read -p "" CVMname
                
    slow_type "How much memory would you like to allocate? (in MBs): "
    read -p "" CRAM

    slow_type "What operating system will you be running? (Linux or Windows): "
    read -p "" COS

    local vmid=$(($(qm list | awk '{print $1}' | sort -n | tail -n 1) + 1))
    local ram_mb=$(echo "$CRAM" | sed 's/[^0-9]*//g')
    local os_type
    
    case "$COS" in
        Linux)
            os_type=l26
            ;;
        "Windows 10")
            os_type=win10
            ;;
        "Windows 11")
            os_type=win11
            ;;
        "Windows 7" | "Windows 8" | "Windows Vista" | "Windows XP")
            os_type="win$(echo "$COS" | tr '[:upper:]' '[:lower:]' | sed 's/windows //')"
            ;;
        *)
            slow_type "Unsupported OS type. Please choose Linux or Windows 10/11/7/8/Vista/XP."
            exit 1
            ;;
    esac

    qm create $vmid --name "$CVMname" --net0 model=virtio,bridge=vmbr0,firewall=1 --memory "$ram_mb" --ostype "$os_type" --storage local
    slow_type "New virtual machine created successfully with ID: $vmid"

    if [ "$Import" -eq 1 ]; then

        slow_type "Restarting the import process..."
        import_vm

    else

        exit

    fi

}

# Function to import a virtual machine
Import_vm() {

    slow_type "Enter the IP Address of the source to Download the file:"
    read -p "" IP

    slow_type "Enter the Virtual Machine's name:"
    read -p "" VMname

    while ! check_vm_exists "$VMname"; do
        slow_type "Virtual machine '$VMname' does not exist. Here are the virtual machines present on your server:"
        
        qm list | awk '{print $2}'

        slow_type "If you are not able to see your virtual machine, you can create one by typing 'Create1'"
        
        read -p "Enter the Virtual Machine's name: " VMname

        if [[ "$VMname" == "Create1" || "$VMname" == "create1" || "$VMname" == "create" ]]; then
            slow_type "Creating a new virtual machine..."
            
            Import=1
            
            create_vm
            exit 0
        fi
    done

    slow_type "Enter the format of the file being downloaded: "
    read -p "" F1

    TEMP_FOLDER="TEMP"
    mkdir -p $TEMP_FOLDER
    cd $TEMP_FOLDER || exit

    # Download the file
    if ! wget "http://$IP/$VMname.$F1"; then
        
        slow_type "Failed to download the file."
        
        exit 1
    fi

    # Check if the file is already in vmdk format
    if [ "${F1,,}" != "vmdk" ]; then
        # Convert the file to VMDK format
        slow_type "Converting the file to VMDK format..."
        
        if ! qemu-img convert -f "$F1" -O vmdk "./$VMname.$F1" "./$VMname.vmdk"; then
            slow_type "Failed to convert the file to VMDK format."
            exit 1
        fi

    else

        slow_type "File is already in VMDK format. Skipping conversion..."
        mv "$VMname.$F1" "$VMname.vmdk"

    fi

    # Find VM's ID using qm list and grep
    VMID=$(qm list | grep -i "$VMname" | awk '{print $1}')

    # Print VM information
    echo "The Virtual Machine $VMname has ID: $VMID"

    # Import the vmdk to the virtual machine
    if ! qm importdisk $VMID "./$VMname.vmdk" local --format vmdk; then
        slow_type "Failed to import the disk."
        exit 1
    fi

    slow_type "Enter the disk number displayed above (look at: unused0:local:105/vm-105-disk-0.vmdk and menstion the number after 'disk')"
    read -p "" Dnum

    disks=$(find / -name "vm-$VMID-disk-*" 2>/dev/null | grep $VMID)

    if echo "$disks" | grep -q "disk-$Dnum"; then
        attach_disk $VMID $Dnum
        echo "Disk attached successfully to VM $VMID"
    else
        echo "Invalid disk number. Please enter a valid disk number."
    fi

    qm set $VMID --boot="order=sata0"

    # Cleanup: Delete the TEMP folder
    cd ..
    rm -rf "$TEMP_FOLDER"

    slow_type "Import process completed successfully!"

    slow_type "Do you want to power on your Virtual Machine? (Type: yes or no)"
    read -p "" power

    if [ "$power" == "yes" ]; then
        qm start $VMID
        slow_type "Your Virtual machine is powered on"

    else
        slow_type "Ok, you can manually power on your Virtul Machine later."
    
    fi

}

attach_disk() {
    local VMID="$1"
    local Dnum="$2"
    
    # Path to the disk
    local path="local:$VMID/vm-$VMID-disk-$Dnum.vmdk"
    
    # Set SATA controller for the Virtual Machine
    qm set $VMID --sata0 $path
}

Export_vm() {

    slow_type "This is the list of Virtual Machines in your server:"
    qm list | awk '{print $2}'

    slow_type "Enter the name of the Virtual Machine to export: "
    read -p "" VMName1

    slow_type "Enter the file format to export (e.g., vmdk, qcow2, raw): "
    read -p "" F2

    supported_formats="alloc-track backup-dump-drive blkdebug blklogwrites blkverify bochs cloop compress copy-before-write copy-on-read dmg file ftp ftps gluster host_cdrom host_device http https iscsi iser luks nbd null-aio null-co nvme parallels pbs preallocate qcow qcow2 qed quorum raw rbd replication snapshot-access throttle vdi vhdx vmdk vpc vvfat zeroinit"

    if ! echo "$supported_formats" | grep -qw "$F2"; then
        slow_type "Unsupported format. Please choose from the following supported formats:"
        echo "$supported_formats"
        exit 1
    fi

    slow_type "Finding VM's ID and stopping the Virtual Machine..."
    VMID1=$(qm list | grep -i "$VMName1" | awk '{print $1}')
    qm stop $VMID1

    slow_type "Configuring and exporting the file..."
    
    loc=$"local":$VMID1

    # Find the disk information and store it in a variable
    disk_info=$(qm config $VMID1 | grep $loc)
    
    # Extract disk names dynamically
    disk_names=$(echo "$disk_info" | awk -F ': ' '{print $1}')
    
    # Count the number of disks
    disk_count=$(echo "$disk_names" | wc -l)
    
    # If there's only one disk, extract its name directly
    if [ "$disk_count" -eq 1 ]; then
        disk_name=$(echo "$disk_names")
    else
        # Print the disk information and prompt the user to select a disk
        slow_type "Multiple disks found for the virtual machine."
        slow_type "Please select the disk you want to export:"
        echo "$disk_names"
        read -p "Enter the disk name: " selected_disk
    
        # Validate user input
        while ! echo "$disk_names" | grep -qw "$selected_disk"; do
            slow_type "Invalid disk name. Please select from the following:"
            echo "$disk_names"
            read -p "Enter the disk name: " selected_disk
        done
    
        disk_name=$selected_disk
    fi
    
    # Now you have the disk name to export
    echo "Selected disk: $disk_name"


    VMDiskname=$(qm config $VMID1 | grep $disk_name: | awk '{print $3}' FS=: OFS=, | cut -d, -f1)
    Path="local:$VMDiskname"
    DiskPath=$(pvesm path $Path)
    VMF1=$(echo "$VMDiskname" | awk -F'.' '{print $2}')

    qemu-img convert -f "$VMF1" -O $F2 "$DiskPath" "./$VMName1.$F2"

    slow_type "Starting the Virtual Machine..."
    qm start $VMID1

    slow_type "Your file that you wanted to be Exported:"
    ls -lh | grep -i "$VMName1"
    pwd

}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --export)
                action="export"
                shift
                ;;
            --import)
                action="import"
                shift
                ;;
            --create)
                action="create"
                shift
                ;;
            --name)
                VM_name=$2
                shift 2
                ;;
            --format)
                F1=$2
                shift 2
                ;;
            --iformat)
                F2=$2
                shift 2
                ;;
            --source)
                IP=$2
                shift 2
                ;;
            --RAM)
                CRAM=$2
                shift 2
                ;;
            --ID)
                vmid=$2
                shift 2
                ;;
            --OS)
                COS=$2
                shift 2
                ;;
            *)
                echo "Invalid option: $1"
                exit 1
                ;;
        esac
    done
}

# Main function
main() {
    slow_type "Welcome! I am a program built by Pranava Rao for managing your Virtual Machines."

    cat .Banner

    # Parse command line arguments
    parse_arguments "$@"

    # If no arguments provided, prompt the user for action
    if [[ $# -eq 0 ]]; then
        interactive_menu
    else
        perform_action
    fi
}

# Function for interactive menu
interactive_menu() {
    slow_type "What would you like to do?"
    read -p "" action
    
    case $action in
        "Import" | "import")
            Import_vm
            ;;
        "Export" | "export")
            Export_vm
            ;;
        "Create VM" | "create" | "create vm")
            create_vm
            ;;
        *)
            slow_type "Invalid option selected. You have the following options: Import, Export, Create VM"
            ;;
    esac
}

PExport_vm() {

    supported_formats="alloc-track backup-dump-drive blkdebug blklogwrites blkverify bochs cloop compress copy-before-write copy-on-read dmg file ftp ftps gluster host_cdrom host_device http https iscsi iser luks nbd null-aio null-co nvme parallels pbs preallocate qcow qcow2 qed quorum raw rbd replication snapshot-access throttle vdi vhdx vmdk vpc vvfat zeroinit"

    if ! echo "$supported_formats" | grep -qw "$F1"; then
        slow_type "Unsupported format. Please choose from the following supported formats:"
        echo "$supported_formats"
        exit 1
    fi

    VMID1=$(qm list | grep -i "$VM_name" | awk '{print $1}')
    qm stop $VMID1

    loc=$"local":$VMID1

    # Find the disk information and store it in a variable
    disk_info=$(qm config $VMID1 | grep $loc)
    
    # Extract disk names dynamically
    disk_names=$(echo "$disk_info" | awk -F ': ' '{print $1}')
    
    # Count the number of disks
    disk_count=$(echo "$disk_names" | wc -l)

    # If there's only one disk, extract its name directly
    if [ "$disk_count" -eq 1 ]; then
        disk_name=$(echo "$disk_names")
    else
        # Print the disk information and prompt the user to select a disk
        slow_type "Multiple disks found for the virtual machine."
        slow_type "Please select the disk you want to export:"
        echo "$disk_names"
        read -p "Enter the disk name: " selected_disk
    
        # Validate user input
        while ! echo "$disk_names" | grep -qw "$selected_disk"; do
            slow_type "Invalid disk name. Please select from the following:"
            echo "$disk_names"
            read -p "Enter the disk name: " selected_disk
        done
    
        disk_name=$selected_disk
    fi

    VMDiskname=$(qm config $VMID1 | grep $disk_name: | awk '{print $3}' FS=: OFS=, | cut -d, -f1)
    Path="local:$VMDiskname"
    DiskPath=$(pvesm path $Path)
    VMF1=$(echo "$VMDiskname" | awk -F'.' '{print $2}')

    qemu-img convert -f "$VMF1" -O $F1 "$DiskPath" "./$VM_name.$F1"

    slow_type "Starting the Virtual Machine..."
    qm start $VMID1

    slow_type "Your file that you wanted to be Exported:"
    ls -lh | grep -i "$VM_name"
    pwd

}

PImport_vm() {

    TEMP_FOLDER="TEMP"
    mkdir -p $TEMP_FOLDER
    cd $TEMP_FOLDER || exit

    # Download the file
    if ! wget "http://$IP/$VM_name.$F2"; then
        
        slow_type "Failed to download the file."
        
        exit 1
    fi

    # Check if the file is already in vmdk format
    if [ "${F2,,}" != "vmdk" ]; then
        
        if ! qemu-img convert -f "$F2" -O vmdk "./$VM_name.$F2" "./$VM_name.vmdk"; then
            slow_type "Failed to convert the file to VMDK format."
            exit 1
        fi
    fi

    # Find VM's ID using qm list and grep
    VMID=$(qm list | grep -i "$VM_name" | awk '{print $1}')

    if ! qm importdisk $VMID "./$VM_name.vmdk" local --format vmdk; then
        slow_type "Failed to import the disk."
        exit 1
    fi

    slow_type "Enter the disk number displayed above (look at: unused0:local:105/vm-105-disk-0.vmdk and menstion the number after 'disk')"
    read -p "" Dnum

    disks=$(find / -name "vm-$VMID-disk-*" 2>/dev/null | grep $VMID)

    if echo "$disks" | grep -q "disk-$Dnum"; then
        attach_disk $VMID $Dnum
        echo "Disk attached successfully to VM $VMID"
    else
        echo "Invalid disk number. Please enter a valid disk number."
    fi

    qm set $VMID --boot="order=sata0"

    # Cleanup: Delete the TEMP folder
    cd ..
    rm -rf "$TEMP_FOLDER"

    slow_type "Import process completed successfully!"

    qm start $VMID
    
    slow_type "Your Virtual machine is powered on"

}

Pcreate_vm() {

    local ram_mb=$(echo "$CRAM" | sed 's/[^0-9]*//g')
    local os_type
    
    case "$COS" in
        Linux)
            os_type=l26
            ;;
        "Windows 10")
            os_type=win10
            ;;
        "Windows 11")
            os_type=win11
            ;;
        "Windows 7" | "Windows 8" | "Windows Vista" | "Windows XP")
            os_type="win$(echo "$COS" | tr '[:upper:]' '[:lower:]' | sed 's/windows //')"
            ;;
        *)
            slow_type "Unsupported OS type. Please choose Linux or Windows 10/11/7/8/Vista/XP."
            exit 1
            ;;
    esac

    slow_type "Creating a new virtual machine with the following configuration:"
    echo "Name: $VM_name; VMID: $vmid; RAM: $ram_mb; OS: $os_type"

    qm create $vmid --name "$VM_name" --net0 model=virtio,bridge=vmbr0,firewall=1 --memory "$ram_mb" --ostype "$os_type" --storage local
    
    slow_type "New virtual machine created successfully"

}

# Function to perform the action based on the provided options
perform_action() {
    case $action in
        export)
            PExport_vm
            ;;
        import)
            PImport_vm
            ;;
        create)
            Pcreate_vm
            ;;
        *)
            echo "Invalid action. Please choose --export, --import, or --create"
            exit 1
            ;;
    esac
}

main "$@"
