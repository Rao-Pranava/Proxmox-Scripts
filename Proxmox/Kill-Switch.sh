#!/bin/bash

# Variables
RPI_IP="<PING SERVER IP ADDRESS>"
PING_COUNT=100
PING_INTERVAL=2
MAX_RETRIES=3
LOSS_THRESHOLD=90
LOG_DIR="/home/Logs"
LOG_FILE="$LOG_DIR/power_loss_monitor.log"

# Ensure the log directory exists
mkdir -p $LOG_DIR

# Function to log messages with a timestamp
log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Function to check ping loss
check_ping_loss() {
  loss=$(ping -c $PING_COUNT $RPI_IP | grep -oP '\d+(?=% packet loss)')
  echo $loss
}

# Function to shutdown all VMs and the Proxmox server
shutdown_vms_and_server() {
  log_message "Power loss detected. Shutting down VMs and the Proxmox server..."
  
  # Stop all running VMs
  for vmid in $(qm list | awk '{if(NR>1) print $1}'); do
    log_message "Shutting down VM ID: $vmid"
    qm shutdown $vmid
    sleep 5  # Give some time for the VM to shutdown gracefully
  done
  
  # Shutdown the Proxmox server
  log_message "Shutting down the Proxmox server..."
  shutdown -h now
}

# Main loop
consecutive_failures=0

while true; do
  loss=$(check_ping_loss)

  if [ "$loss" -ge "$LOSS_THRESHOLD" ]; then
    consecutive_failures=$((consecutive_failures + 1))
    
    if [ "$consecutive_failures" -ge "$MAX_RETRIES" ]; then
      log_message "Ping loss detected: $loss%. Consecutive failures: $consecutive_failures"
      shutdown_vms_and_server
      break
    fi
  else
    consecutive_failures=0
  fi

  sleep $((PING_INTERVAL * 60))
done
