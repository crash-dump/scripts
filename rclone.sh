#!/usr/bin/env bash

# Check that rclone exists
if [ ! -f /etc/profiles/per-user/$USER/bin/rclone ]; then
  echo "[FATAL] Failed to source rclone binary from environment"; sleep 1s
  exit -1
fi

# Output error if missing configuration file
if [ ! -f $HOME/.config/rclone/rclone.conf ]; then
  echo "[ERROR] Cannot locate '$HOME/.config/rclone/rclone.conf'!"; sleep 1s
  echo "[ERROR] Please locate configuration files and/or rerun setup before running script. Aborting Execution."
  exit 1
fi

# Sync to Cloud
rclone sync ~/Public b2:us3-share-public --log-level=DEBUG --log-file=$HOME/.config/rclone/rclone.log

# Run notify-send, assuming a successful execution of script
notify-send "Finished Executing Background Service" "Service 'rclone-sync' executed successfully"
