#!/bin/bash

# ==========================================
# System Information & Health Check
# Project: Bash & Git DevOps Automation Toolkit
# ==========================================

set -Eeuo pipefail

# Error handling function
handle_error() {
    local exit_code=$?
    local line_number="$1"

    printf "ERROR: Command failed at line %s (exit status: %s)\n" \
        "$line_number" "$exit_code" >&2
}

trap 'handle_error "$LINENO"' ERR

# ==========================================
# 1. Check Required Commands
# ==========================================

REQUIRED_COMMANDS=(
    awk
    df
    free
    nproc
    tee
    date
    mkdir
    dirname
    uname
    hostname
    id
    uptime
)

echo "Checking required commands..."

for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: Required command '$cmd' is not installed."
        exit 1
    fi
done

echo "All required commands are available."

# ==========================================
# 2. Log Configuration
# ==========================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LOG_DIR="${SCRIPT_DIR}/logs"

mkdir -p "$LOG_DIR"

TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"

LOG_FILE="${LOG_DIR}/system-health-${TIMESTAMP}-${BASHPID}.log"

# ==========================================
# 3. Collect System Information
# ==========================================

HOSTNAME_VALUE="$(hostname)"

CURRENT_USER="$(id -un)"

USER_ID="$(id -u)"

OS_NAME="Unknown"

if [[ -r /etc/os-release ]]; then
    OS_NAME="$(. /etc/os-release && printf '%s' "${PRETTY_NAME:-Unknown}")"
fi

KERNEL_VERSION="$(uname -r)"

ARCHITECTURE="$(uname -m)"

CPU_MODEL="$(
    awk -F: '/model name|Hardware/ {
        gsub(/^[ \t]+/, "", $2)
        print $2
        exit
    }' /proc/cpuinfo
)"

CPU_CORES="$(nproc)"

if [[ -z "$CPU_MODEL" ]]; then
    CPU_MODEL="Unknown"
fi

MEMORY_INFO="$(
    free -h | awk '$1 == "Mem:" {
        printf "Total: %s | Used: %s | Available: %s", $2, $3, $7
    }'
)"

DISK_INFO="$(
    df -hP / | awk 'NR == 2 {
        printf "Filesystem: %s | Size: %s | Used: %s | Available: %s | Usage: %s",
        $1, $2, $3, $4, $5
    }'
)"

UPTIME_INFO="$(uptime -p)"

# ==========================================
# 4. Generate System Report
# ==========================================

{
    echo "=============================================="
    echo "       SYSTEM INFORMATION & HEALTH REPORT"
    echo "=============================================="

    echo

    echo "[ SYSTEM INFORMATION ]"

    printf "%-20s: %s\n" "Hostname" "$HOSTNAME_VALUE"
    printf "%-20s: %s\n" "Operating System" "$OS_NAME"
    printf "%-20s: %s\n" "Kernel Version" "$KERNEL_VERSION"
    printf "%-20s: %s\n" "Architecture" "$ARCHITECTURE"
    printf "%-20s: %s\n" "System Uptime" "$UPTIME_INFO"

    echo

    echo "[ USER INFORMATION ]"

    printf "%-20s: %s\n" "Current User" "$CURRENT_USER"
    printf "%-20s: %s\n" "User ID" "$USER_ID"

    echo

    echo "[ CPU INFORMATION ]"

    printf "%-20s: %s\n" "CPU Model" "$CPU_MODEL"
    printf "%-20s: %s\n" "CPU Cores" "$CPU_CORES"

    echo

    echo "[ MEMORY INFORMATION ]"

    printf "%s\n" "$MEMORY_INFO"

    echo

    echo "[ DISK INFORMATION ]"

    printf "%s\n" "$DISK_INFO"

    echo

    echo "[ DEPENDENCY CHECK ]"

    echo "All required commands are available."

    echo

    echo "=============================================="
    echo "          REPORT COMPLETED SUCCESSFULLY"
    echo "=============================================="

    echo "Generated At: $(date '+%Y-%m-%d %H:%M:%S')"

} | tee "$LOG_FILE"

echo
echo "Report saved successfully:"
echo "$LOG_FILE"
