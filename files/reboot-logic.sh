#!/bin/bash

# SPDX-License-Identifier: MIT
# Copyright (c) 2026 straysheep-dev

# shellcheck disable=SC2034

# Reboot the system if a pending kernel or package update requires it.
# Designed to run as a cron job after update-packages.sh completes.
#
# Cron Example (run as root) 1 hour after update-packages.sh:
# 0 4 * * * /bin/bash /usr/local/bin/reboot-logic.sh

BLUE="\033[01;34m"
GREEN="\033[01;32m"
YELLOW="\033[01;33m"
RED="\033[01;31m"
BOLD="\033[01;01m"
RESET="\033[00m"

reboot_required=false

# RedHat / Fedora
if (command -v dnf > /dev/null)
then
    # dnf needs-restarting --help
    # -r, --reboothint      only report whether a reboot is required (exit code 1) or not (exit code 0)
    dnf needs-restarting -r >/dev/null
    rc=$?
    if [[ "$rc" -eq 1 ]]
    then
        reboot_required=true
    elif [[ "$rc" -gt 1 ]]
    then
        echo -e "[${RED}*${RESET}] ${BOLD}Exit code not 0 or 1, dnf reboot check failed...${RESET}"
        exit 1
    fi
# Debian / Ubuntu
elif [ -f /run/reboot-required ]
then
    reboot_required=true
fi

if [ "$reboot_required" = "true" ]
then
    echo -e "[${BLUE}>${RESET}] ${BOLD}Reboot required, rebooting now...${RESET}"
    sudo systemctl reboot
else
    echo -e "[${BLUE}>${RESET}] ${BOLD}No reboot required.${RESET}"
fi
