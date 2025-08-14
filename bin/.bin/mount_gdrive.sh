#!/bin/bash
rclone mount gdrive: ~/GoogleDrive \
  --vfs-cache-mode full \
  --allow-other \
  --daemon
