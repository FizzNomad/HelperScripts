#!/bin/bash

# Function to validate user input
validate_input() {
    local option_name=$1
    local option_value=$2

    case $option_name in
        minute|hour|day_of_month|month|day_of_week)
            if [[ ! $option_value =~ ^(\*|[0-9]|1[0-9]|2[0-3]|[0-9]-[0-9]|[0-9],)+$ ]]; then
                echo "Invalid $option_name value: $option_value"
                exit 1
            fi
            ;;
        command)
            if [[ -z $option_value ]]; then
                echo "Command value cannot be empty."
                exit 1
            fi
            ;;
        email)
            if [[ ! $option_value =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                echo "Invalid email address: $option_value"
                exit 1
            fi
            ;;
    esac
}

read -p "Do you want to specify a log file path? (y/n): " LOG_CHOICE

if [[ $LOG_CHOICE =~ ^[Yy]$ ]]; then
    read -p "Enter the full path for the log file (e.g., /var/log/mycron.log): " LOG_FILE
    if [[ ! -f $LOG_FILE ]]; then
        touch $LOG_FILE || { echo "Error creating log file. Please check the path and try again."; exit 1; }
    fi
else
    LOG_FILE="/var/log/cron.log"
fi

# Prompt the user for input
read -p "Enter minute (0-59 or *): " MINUTE
validate_input "minute" "$MINUTE"

read -p "Enter hour (0-23 or *): " HOUR
validate_input "hour" "$HOUR"

read -p "Enter day of month (1-31 or *): " DAY_OF_MONTH
validate_input "day_of_month" "$DAY_OF_MONTH"

read -p "Enter month (1-12 or *): " MONTH
validate_input "month" "$MONTH"

read -p "Enter day of week (0-6 for Sunday-Saturday or *): " DAY_OF_WEEK
validate_input "day_of_week" "$DAY_OF_WEEK"

read -p "Enter command to run: " COMMAND
validate_input "command" "$COMMAND"

read -p "Enter email address to receive logs (leave blank for no email): " EMAIL
validate_input "email" "$EMAIL"

# Create the cron job entry
CRON_ENTRY="$MINUTE $HOUR $DAY_OF_MONTH $MONTH $DAY_OF_WEEK $COMMAND"

# Add email option if specified
if [[ -n $EMAIL ]]; then
    CRON_ENTRY+=" | mail -s 'Cron Job Output' $EMAIL"
fi

# Add the entry to the crontab file
(crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab -

echo "Cron job successfully created:"
echo "$CRON_ENTRY"
