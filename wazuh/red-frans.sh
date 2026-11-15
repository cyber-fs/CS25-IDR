#!/bin/bash

# Wazuh Red Team Simulation
# Avsedd endast för den isolerade labbmiljön.
#
# Simulerar:
# - Randomiserad användare
# - Sudo-konfiguration
# - FIM: create / modify / delete
# - Ändring av /etc/hosts
# - Simulerad privilege escalation
# - Simulerad defense evasion
#
# Alla pauser är randomiserade mellan 1 och 3 sekunder.
#
#


set -u

TEST_USER="red-frans-$(tr -dc 'a-z0-9' </dev/urandom | head -c 3)"
RANDOM_DIR="red_$(tr -dc 'a-z0-9' </dev/urandom | head -c 3)"
TEST_DIR="/etc/$RANDOM_DIR"

sleep_random() {
    sleep "$((RANDOM % 3 + 1))"
}

echo "================================="
echo "[***] Starting RED TEAM Wazuh FIM simulation"
echo "[***] Copyright © 2026 FRANS"
sleep_random

# --------------------------------------------------
# Create user
# --------------------------------------------------

echo "[+] Creating a simulated hacker!"

sudo useradd -m "$TEST_USER"

sleep_random

# --------------------------------------------------
# Add user to sudo group
# --------------------------------------------------

echo "[+] Adding to group"

sudo usermod -aG sudo "$TEST_USER"

sleep_random

# --------------------------------------------------
# Configure temporary password
# --------------------------------------------------

echo "[+] Configuring temporary password"

echo "$TEST_USER ALL=(ALL) NOPASSWD: ALL" |
    sudo tee "/etc/sudoers.d/$TEST_USER" > /dev/null

sudo chmod 440 "/etc/sudoers.d/$TEST_USER"

sleep_random

# --------------------------------------------------
# Create random FIM directory
# --------------------------------------------------

echo "[+] Creating test dirs"

sudo mkdir -p "$TEST_DIR"

sudo chown "$TEST_USER:$TEST_USER" "$TEST_DIR"

sleep_random

# --------------------------------------------------
# Switch to simulated user
# --------------------------------------------------

echo "[!] Switching users"

sleep_random

sudo -iu "$TEST_USER" bash <<EOF

echo "[+] Current user:"
whoami

sleep \$((RANDOM % 3 + 1))

# --------------------------------------------------
# Create FIM test file
# --------------------------------------------------

echo "[+] Creating stuff"

echo "Red Team simulation" > "$TEST_DIR/hello.test"

sleep \$((RANDOM % 3 + 1))

# --------------------------------------------------
# Modify FIM test file
# --------------------------------------------------

echo "[+] Modifying some things"

echo "Modified during simulated incident" >> "$TEST_DIR/hello.test"

sleep \$((RANDOM % 3 + 1))

# --------------------------------------------------
# Create second FIM test file
# --------------------------------------------------

echo "[+] Creating more stuff."

echo "Temporary simulated payload" > "$TEST_DIR/payload.test"

sleep \$((RANDOM % 3 + 1))

# --------------------------------------------------
# Modify /etc/hosts
# --------------------------------------------------

echo "[!] Executing on objectives"

sudo sh -c 'echo "10.0.6.20 google.com" >> /etc/hosts'

sleep \$((RANDOM % 3 + 1))

# --------------------------------------------------
# Simulate privilege escalation
# --------------------------------------------------

echo "[+] Simulating a fun event"

logger -t REDTEAM_SIMULATION \
    "Simulated privilege escalation activity by $TEST_USER"

sleep \$((RANDOM % 3 + 1))

# --------------------------------------------------
# Simulate defense evasion
# --------------------------------------------------

echo "[+] Doing defense evasion"

logger -t REDTEAM_SIMULATION \
    "Simulated defense evasion activity by $TEST_USER"

sleep \$((RANDOM % 3 + 1))

# --------------------------------------------------
# Delete FIM test files
# --------------------------------------------------

echo "[-] Removing files"

rm -f "$TEST_DIR/hello.test"
rm -f "$TEST_DIR/payload.test"

sleep \$((RANDOM % 3 + 1))

EOF

# --------------------------------------------------
# Restore /etc/hosts
# --------------------------------------------------

echo "[-] Restoring files"

sudo sed -i '/^10\.0\.6\.20 google\.com$/d' /etc/hosts

sleep_random

# --------------------------------------------------
# Remove test directory
# --------------------------------------------------

echo "[-] Removing temp"

sudo rmdir "$TEST_DIR"

sleep_random

# --------------------------------------------------
# Remove temporary sudo configuration
# --------------------------------------------------

echo "[-] Cleaning up stuff"

sudo rm -f "/etc/sudoers.d/$TEST_USER"

sleep_random

# --------------------------------------------------
# Remove simulated user
# --------------------------------------------------

echo "[-] Removing users"

sudo userdel -r "$TEST_USER" 2>/dev/null || true

sleep_random


echo "[***] DONE! - Go to Wazuh dashboard."
echo "================================="
