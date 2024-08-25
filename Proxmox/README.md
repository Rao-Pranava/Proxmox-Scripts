# Proxmox Automation Scripts

All these scripts are to be run on the Proxmox Server

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

## Kill-Switch.sh

This automated scripts shuts down the Proxmox server as well as the Virtual Machine after it identifies a power out age using a Ping mechanism of another system (Ping Server) which responds to the Ping messages when the power is alive and then goes black out when the power is cut.

### Setup

1. Add the IP Address of the Server that you want to PING as a server that would not respond when the power is off.

![image](https://github.com/user-attachments/assets/5607a97e-94a8-4475-8616-86061490aa67)

2. Make file executable.

```
chmod +x Kill-Switch.sh
```

3. Add a cronjob to run this bash script at all time.

```
sudo nano /etc/crontab
```
And add the following line

```
* * * * * /path/to/Kill-Switch.sh
```
