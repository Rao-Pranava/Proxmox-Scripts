# Proxmox Automation Scripts

All these scripts are to be run on the Proxmox Server

```
git clone https://github.com/Rao-Pranava/Automation-Scripts.git
```

## Proxmox.sh
This file automates the process of exporting and importing Virtual machine Disk files

### Useage

```
bash Proxmox.sh --help
```
<img width="1147" height="786" alt="image" src="https://github.com/user-attachments/assets/45f9233e-a332-4bf8-a3a6-ff27b802b89c" />

## Kill-Switch1.sh

This automated scripts shuts down the Proxmox server as well as the Virtual Machine after it identifies a power out age using a Ping mechanism of another system (Ping Server) which responds to the Ping messages when the power is alive and then goes black out when the power is cut.

### Setup

1. Add the IP Address of the Server that you want to PING as a server that would not respond when the power is off.

![image](https://github.com/user-attachments/assets/5607a97e-94a8-4475-8616-86061490aa67)

2. Make file executable.

```
chmod +x Kill-Switch1.sh
```

3. Add a cronjob to run this bash script at all time.

```
sudo nano /etc/crontab
```
And add the following line

```
* * * * * root /path/to/Kill-Switch1.sh
```

## Kill-Switch2.sh

This automated scripts shuts down the Proxmox server as well as the Virtual Machine after it identifies a power loss using the `upower` tool. This meastures battery power and when it reaches 30% or below, it power off the server.

### Setup

1. Install  `upower`.

```
apt install upower
```

![image](https://github.com/user-attachments/assets/c760d464-5396-4110-af75-1833684f7eed)

2. using the `upower` find the location of your battery and edit the location of the battery in the script.

```
upower -e
```

![image](https://github.com/user-attachments/assets/8d7e1d4f-acdb-4df2-a68e-aaf5d8a8b4a9)

```
/org/freedesktop/UPower/devices/battery_BAT1 #Your Battery Location
```

![image](https://github.com/user-attachments/assets/c11bd24a-071f-43af-88e0-3de1df6ced2c)

Then save and exit.


3. Make file executable.

```
chmod +x Kill-Switch2.sh
```

3. Add a cronjob to run this bash script at all time.

```
sudo nano /etc/crontab
```
And add the following line

```
* * * * * root /path/to/Kill-Switch2.sh
```

## export_all_vms.sh
This script is a part of automating the process of backing up all the power offed systems in your Proxmox Server.

You can find the Detailed Blog about reasons and Motives about this tool [Here]([https://pranavarao.tech](https://pranavarao.tech/Blogs/Tech/backing-up-virtual-machines-in-promox/index.html))

### Setup

1. Make the `export_all_vms.sh` script executable

```
chmod +x export_all_vms.sh
```

2. Add the followign cron job to the cron of your proxmox server.

```
crontab -e
```

Enter the following content:

```
5 0 * * 0 /home/export_all_vms.sh >> /var/log/vm_backup.log 2>&1
```
*This will run the `export_all_vms.sh` script at 00:05 hours on all Sundays*

![image](https://github.com/user-attachments/assets/4e21a58a-8b47-443a-9b9d-8f61aa11e9d0)

Now, exit the editor

3. That is it, if you want to have a test run, you can run the following command

```
./export_all_vms.sh
```

![image](https://github.com/user-attachments/assets/a37766a2-7680-4454-b020-99e4244feebc)

-----------------

# Useful Commands

If you want to download the file from your server to the local computer, you can use this command:
```
scp root@<IP Address>:<File Location> .
```
