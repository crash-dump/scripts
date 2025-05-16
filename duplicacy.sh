#!/usr/bin/env bash

# Check $PATH for duplicacy
if [ ! -f /etc/profiles/per-user/$USER/bin/duplicacy ]; then
  echo "[FATAL] Failed to load binary from \$PATH!";  sleep 1s
  exit -1
fi

# Output error if missing configuration file
if [ ! -d $HOME/.duplicacy ]; then
  echo "[ERROR] Cannot locate '$HOME/.duplicacy'!"; sleep 1s
  echo "[ERROR] Please locate configuration files and/or rerun setup before running script. Aborting Execution."
  exit 1
fi

# Grab Current date
timestamp=$(date +'%Y%m%d-%H%M%S')

# Define Functions
function backup_all() {
  # Backup Default Storage
  duplicacy backup -threads 4 > ~/.duplicacy/logs/backup/default-$timestamp

  # Backup Local Storage
  duplicacy backup -threads 4 -storage localbackup > ~/.duplicacy/logs/backup/localbackup-$timestamp

  # Backup Encrypted Vault
  #duplicacy backup -threads 4 -storage vaultbackup > ~/.duplicacy/logs/backup/vaultbackup-$timestamp
}

function prune_all() {
  # Prune Default Storage
  duplicacy prune -keep 7:1 -keep 4:30 -keep 0:365 > ~/.duplicacy/logs/prune/default-$timestamp

  # Prune Local Storage
  duplicacy prune -keep 7:1 -keep 4:30 -keep 0:365 -storage localbackup > ~/.duplicacy/logs/prune/localbackup-$timestamp

  # Prune Encrypted Vault
  #duplicacy prune -keep 7:1 -keep 4:30 -keep 1:365 -keep 0:3650 -storage vaultbackup > ~/.duplicacy/logs/prune/vaultbackup-$timestamp
}


function verify_all() {
  # Check Default Storage
  duplicacy check -persist > ~/.duplicacy/logs/check/default-$timestamp

  # Check Local Storage
  duplicacy check -persist -storage localbackup > ~/.duplicacy/logs/check/localbackup-$timestamp

  # Check Encrypted Vault
  #duplicacy check -persist -storage vaultbackup > ~/.duplicacy/logs/check/vaultbackup-$timestamp
}

# Perform Backup
backup_all

# If sunday, run prune and check operations
if [ $(date +'%A') == "Sunday" ]; then
  prune_all; verify_all
fi

# Run notify-send, assuming a successful execution of script
notify-send "Finished Executing Background Service" "Service 'duplicacy-backup' executed successfully"
