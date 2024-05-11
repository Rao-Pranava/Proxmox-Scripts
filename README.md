# Automation-Scripts
This repositry is a collection of all the scripts that is used for automating stuffs

![AI Images](https://github.com/Rao-Pranava/Automation-Scripts/assets/93928268/a3c8a0c6-2795-4953-af57-44e558460204)


# Proxmox
[Proxmox](https://github.com/Rao-Pranava/Automation-Scripts/tree/main/Proxmox/) folder contains an automated script for Importing and Exporting the virtual machines

# Backup script

[Backup](https://github.com/Rao-Pranava/Automation-Scripts/tree/main/Backup/) is a simple Bash script which uses `scp` to connect to a file server and then store it in a specified location (such as an external `Hard Disk`) for any Linux Operating System.

This script is written to run by a `cronjob` to backup the files at a regular interval (Every 7 days) and also to delete the older copies of the backup

# Apache2
[Apache2](https://github.com/Rao-Pranava/Automation-Scripts/tree/main/Apache2) is a automated script to download and install **Apache2**, **MySQL** along with **PHP** on a **Ubuntu System** (only tested on a Ubuntu Server as of now)
