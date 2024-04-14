# Backup script

This is a simple Bash script which uses `scp` to connect to a file server and then store it in a specified location (such as an external `Hard Disk`) for any Linux Operating System.

This script is written to run by a `cronjob` to backup the files at a regular interval (Every 7 days) and also to delete the older copies of the backup

## Prerequisites for this work

1. Install `sshpass` to pass in passwords while running `scp`
```
sudo apt install sshpass
```

2. Edit the file `Backup.sh` and all the details that the application needs. (Edit the `Constants` part of the code.)
```
nano Backup.sh
```

## Useage

1. Make the file executable.

```
chmod +x Backup.sh
chmod +x Backup1.sh
```

2. Run the program.

For `Desktop` environment.

```
sudo bash Backup.sh
```

For `Server` environment.

```
sudo bash Backup1.sh
```

## Run through Cronjob

A cronjob that runs this script on Every Sunday at 1am.

1. Open the crontab file
```
sudo nano /etc/crontab
```

2. Go to the last and then add the following line.
```
0 1 * * 0 root /<Location>/Backup.sh
```

or 

```
0 1 * * 0 root /<Location>/Backup1.sh
```

# Disclaimer

This code is specifically written to store the Backup files on an external Hard Disk. If you need any changes to your environment please make changes accordingly.