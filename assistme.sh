#!/bin/bash

# ANSI escape codes for colors
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
RESET="\033[0m"

# Function to display commands for a given category
function display_category() {
  local category_name="$1"
  echo -e "${CYAN}${category_name} Commands:${RESET}"
  while IFS=',' read -r category command description; do
    if [ "$category" == "$category_name" ]; then
      echo -e "${description}: ${GREEN}${command}${RESET}"
    fi
  done < commands.txt
}

while true; do
  echo -e "${YELLOW}Select a category:${RESET}"
  options=("Service Scanning" "Web Enumeration" "Public Exploits" "Using Shells" "Privilege Escalation" "Transferring Files" "Quit")
  select opt in "${options[@]}"; do
    case $opt in
      "Service Scanning"|"Web Enumeration"|"Public Exploits"|"Using Shells"|"Privilege Escalation"|"Transferring Files")
        display_category "$opt"
        break
        ;;
      "Quit")
        exit 0
        ;;
      *)
        echo "Invalid option. Please try again."
        ;;
    esac
  done
  echo
  read -p "Press ENTER to continue or CTRL+C to quit."
  echo
done
