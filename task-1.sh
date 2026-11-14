#!/bin/bash
set +o pipefail

echo "===== SHELL INFORMATION ====="

echo "===== Current Shell ====="
echo "$SHELL"

echo "===== Current Process ====="
ps -p $$

echo "===== Bash Version ====="
bash --version | head -n 1

echo "=====Shell Process ID ====="
echo $$

echo "===== Current User ====="
whoami

echo "===== Directory Disk Usage ====="
du -xhd1 . | head -n 5

echo "===== Intentional Runtime Error ====="
dz -xhd1 . | head -n 5

echo $?
