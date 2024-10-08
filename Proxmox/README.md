# Proxmox Automation Scripts

All these scripts are to be run on the Proxmox Server

```
git clone https://github.com/Rao-Pranava/Automation-Scripts.git
```

## Proxmox.sh
This file automates the process of exporting and importing Virtual machine Disk files

### Useage

There are two ways to use the script, `Interactive` mood and the `Automated` mood.

#### Interactive
```
bash Automation.sh
```

##### Importing the VM
![image](https://github.com/Rao-Pranava/Automation-Scripts/assets/93928268/5ae6ea7b-d2cd-4685-9c75-94ef9f722167)

![image](https://github.com/Rao-Pranava/Automation-Scripts/assets/93928268/ee3a977c-4b6d-4202-be6f-fa7a496f2588)

##### Exporting the VM
![image](https://github.com/Rao-Pranava/Automation-Scripts/assets/93928268/2e971203-7f3d-40fd-a204-ccb40fb40ef2)

##### Create a VM
![image](https://github.com/Rao-Pranava/Automation-Scripts/assets/93928268/6c2a996f-4b8b-476f-a68f-a159eacc022f)


#### Automated mood.

##### Help

```
bash Proxmox.sh --help
```
![image](https://github.com/Rao-Pranava/Automation-Scripts/assets/93928268/afb2e504-fb03-4815-b8a5-e3ee7e5b78ad)

##### Importing a VM

```
bash Proxmox.sh --import --source <IP-Address> --name <name> --format <format>
```
![image](https://github.com/Rao-Pranava/Automation-Scripts/assets/93928268/8eb5b7c0-f1f8-4487-907b-2e7c0266b10c)

![image](https://github.com/Rao-Pranava/Automation-Scripts/assets/93928268/ee3a977c-4b6d-4202-be6f-fa7a496f2588)


##### Exporting the VM

```
bash Proxmox.sh --export --name <name> --format <format>
```
![image](https://github.com/Rao-Pranava/Automation-Scripts/assets/93928268/77003e79-1875-46d0-8e23-e3a9999798b5)

##### Creating a VM

```
bash Proxmox.sh --create --name <name> --OS <OS> --RAM 2048 --ID <ID>
```
![image](https://github.com/Rao-Pranava/Automation-Scripts/assets/93928268/76a055f8-7a48-4b06-8c64-a804335849e4)

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

# Useful Commands

If you want to download the file from your server to the local computer, you can use this command:
```
scp root@<IP Address>:<File Location> .
```
