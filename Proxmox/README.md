# Proxmox
This file automates the process of exporting and importing Virtual machine Disk files

## Useage

There are two ways to use the script, `Interactive` mood and the `Automated` mood.

### Interactive
```
bash Automation.sh
```

#### Importing the VM

#### Exporting the VM
![image](https://github.com/Rao-Pranava/Automation-Scripts/assets/93928268/2e971203-7f3d-40fd-a204-ccb40fb40ef2)

#### Create a VM


### Automated mood.

#### Help

```
bash Proxmox.sh --help
```
![image](https://github.com/Rao-Pranava/Automation-Scripts/assets/93928268/afb2e504-fb03-4815-b8a5-e3ee7e5b78ad)


#### Exporting the VM

```
bash Proxmox.sh --export --name <name> --format <format>
```
![image](https://github.com/Rao-Pranava/Automation-Scripts/assets/93928268/77003e79-1875-46d0-8e23-e3a9999798b5)

#### Creating a VM

```
bash Proxmox.sh --create --name <name> --OS <OS> --RAM 2048 --ID <ID>
```
![image](https://github.com/Rao-Pranava/Automation-Scripts/assets/93928268/76a055f8-7a48-4b06-8c64-a804335849e4)
