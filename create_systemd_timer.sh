#!/bin/bash

validate_input() {
    local option_name=$1
    local option_value=$2

    case $option_name in
        OnCalendar)
            if [[ ! $option_value =~ ^[A-Za-z0-9\-\*/]+(\s+[A-Za-z0-9\-\*/]+)*$ ]]; then
                echo "Invalid OnCalendar value. Please refer to the systemd.time manual for correct syntax."
                exit 1
            fi
            ;;
        OnBootSec|OnUnitActiveSec)
            if [[ ! $option_value =~ ^([0-9]+(s|min|h|d|w|m|y))+$ ]]; then
                echo "Invalid ${option_name} value. Please use a value like 5s, 10min, 3h, 1d, 2w, 3m, or 1y."
                exit 1
            fi
            ;;
    esac
}

update_or_create_timer() {
    local service_path="/etc/systemd/system/${SERVICE_NAME}.service"
    local timer_path="/etc/systemd/system/${SERVICE_NAME}.timer"

    if [ -f "$timer_path" ]; then
        read -p "Timer already exists. Do you want to update it? (y/n): " UPDATE_CHOICE
        if [[ ! $UPDATE_CHOICE =~ ^[Yy]$ ]]; then
            echo "Exiting without updating the timer."
            exit 0
        fi
    fi

    # Move the files to the systemd folder and enable the timer
    if sudo mv /tmp/${SERVICE_NAME}.service "$service_path" && sudo mv /tmp/${SERVICE_NAME}.timer "$timer_path"; then
        echo "Service and timer files created and moved to /etc/systemd/system/"
    else
        echo "Error moving files. Check permissions and try again."
        exit 1
    fi
}

read -p "Enter a name for the systemd service and timer (e.g., mycustomtimer): " SERVICE_NAME
read -p "Enter the full path to the script you want to run (e.g., /home/user/myscript.sh): " SCRIPT_PATH

if [ ! -f "$SCRIPT_PATH" ]; then
    echo "Script not found at the specified path. Please check the path and try again."
    exit 1
fi

DESCRIPTION="Custom systemd timer for ${SERVICE_NAME}"
USER=$(whoami)

echo "Please choose a scheduling option:"
echo "1. OnCalendar: Schedule based on calendar events or specific timestamps (e.g., every 10 minutes)."
echo "2. OnBootSec: Schedule relative to when the system boots up (e.g., 5 minutes after boot)."
echo "3. OnUnitActiveSec: Schedule relative to the last time the unit was activated (e.g., 1 hour after the previous run)."

read -p "Enter the option number (1, 2, or 3): " OPTION

case $OPTION in
    1)
        OPTION_NAME="OnCalendar"
        read -p "Enter the OnCalendar value (e.g., *:0/10 for every 10 minutes): " OPTION_VALUE
        validate_input "${OPTION_NAME}" "${OPTION_VALUE}"
        ;;
    2)
        OPTION_NAME="OnBootSec"
        read -p "Enter the OnBootSec value (e.g., 5min for 5 minutes after boot): " OPTION_VALUE
        validate_input "${OPTION_NAME}" "${OPTION_VALUE}"
        ;;
    3)
        OPTION_NAME="OnUnitActiveSec"
        read -p "Enter the OnUnitActiveSec value (e.g., 1h for 1 hour after the previous run): " OPTION_VALUE
        validate_input "${OPTION_NAME}" "${OPTION_VALUE}"
        ;;
    *)
        echo "Invalid option. Exiting."
        exit 1
        ;;
esac

# Create the service file
cat > /tmp/${SERVICE_NAME}.service << EOL
[Unit]
Description=$DESCRIPTION

[Service]
ExecStart=$SCRIPT_PATH
User=$USER
EOL

# Create the timer file
cat > /tmp/${SERVICE_NAME}.timer << EOL
[Unit]
Description=$DESCRIPTION

[Timer]
$OPTION_NAME=$OPTION_VALUE
Unit=${SERVICE_NAME}.service

[Install]
WantedBy=timers.target
EOL

# Call the function to update or create the timer
update_or_create_timer

# Reload systemd daemon, enable and start the timer
if sudo systemctl daemon-reload; then
    echo "systemd daemon reloaded."
else
    echo "Error reloading systemd daemon."
    exit 1
fi

if sudo systemctl enable ${SERVICE_NAME}.timer; then
    echo "Timer enabled."
else
    echo "Error enabling timer."
    exit 1
fi

read -p "Do you want to start the timer now? (y/n): " START_CHOICE
if [[ $START_CHOICE =~ ^[Yy]$ ]]; then
    if sudo systemctl start ${SERVICE_NAME}.timer; then
        echo "Timer started successfully."
        echo "To check the status of the timer, run 'systemctl status ${SERVICE_NAME}.timer'"
    else
        echo "Error starting timer."
        exit 1
    fi
else
    echo "Timer not started. You can start it later with 'systemctl start ${SERVICE_NAME}.timer'"
fi
