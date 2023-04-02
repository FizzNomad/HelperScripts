# HelperScripts
Just little scripts and functions to make my life better.

Covid did a number on my brain so in here you will find little things i've come up with to help me out.

# assistme.sh Script

This script provides an interactive cheat sheet for various categories, such as Service Scanning, Web Enumeration, Public Exploits, Using Shells, Privilege Escalation, and Transferring Files. It reads the commands and their descriptions from a `commands.txt` file and displays them based on the user-selected category.

## Usage

1. Ensure you have the `commands.txt` file in the same directory as the `assistme.sh` script or provide the full path to the file in the script.
2. Make sure the `assistme.sh` script is executable by running `chmod +x assistme.sh`.
3. Run the script by executing `./assistme.sh`.
4. Select a category by entering its corresponding number and pressing Enter.
5. View the commands and descriptions for the selected category.
6. Press Enter to return to the category selection menu or use Ctrl+C to exit the script.

## commands.txt Format

The `commands.txt` file should have the following format, using a comma `,` as the delimiter between fields:

  Category1,Command1,Description1


## Maintaining the Script

To add or modify commands and descriptions for each category, simply edit the `commands.txt` file following the format specified above. To add new categories or modify existing ones, update the `options` array in the `assistme.sh` script accordingly.

If you need to change the colors or text formatting in the script, you can edit the ANSI escape codes for colors at the beginning of the script.

---

## create_systemd_timer.sh
This little script automates the steps to create a systemd timer and service.
It was a good exercise as it started fairly simple, and then I thought about the user being able to select the name of the service,or to update an existing timer. It had no error handling so that was included along with some user friendly output.

To test it I created a test_script.sh
```
#!/bin/bash

LOG_FILE="/tmp/test_script.log"

echo "Test script exectuted at $(date)" >> $LOG_FILE
```
To stop and disable the timer and services created you can issue the following commands:

```
sudo systemctl stop your_timer_name.timer
sudo systemctl disable your_timer_name.timer
```
To delete the files:
```
sudo rm /etc/systemd/system/your_timer_name.timer
sudo rm /etc/systemd/system/your_timer_name.service
```
Finally, reload the systemd daemon:
`sudo systemctl daemon-reload`

### So how will this help me as a Pentester?
This went from being a lesson in HTB that got me wanting to automate this process and developing it into something bigger.
I needed to remind myself why I was doing this, and came up with the following applications:

1. Scheduling scans and reconnaissance tasks: You can create systemd timers to schedule regular scans and recon activities using tools like Nmap, Nikto, or automated vulnerability scanners. This can help you monitor your target's environment for changes and new vulnerabilities that may be introduced over time.

2. Periodic data exfiltration: If you've gained access to a system during a penetration test, you can use systemd timers to exfiltrate data at regular intervals. For example, you could create a script that collects sensitive information and sends it to a remote server. You can then use a timer to run the script at specific intervals.

3. Persistent access: In a pentesting scenario, you may want to maintain access to a compromised system. You can create a systemd timer to periodically check if your backdoor or reverse shell is still active, and if not, attempt to re-establish the connection.

4. Running timed attacks: Some attacks, such as brute-force or password spraying, may be more effective or stealthy when conducted over an extended period. You can use systemd timers to schedule these attacks at specific times, spreading the attempts out and potentially evading detection

##### Why not just use Cron?
I probably will. I just went down this path and im still figuring out crons notation.

```
* * * * * command to be executed
- - - - -
| | | | |
| | | | ----- Day of the week (0 - 7) (Sunday is 0 or 7)
| | | ------- Month (1 - 12)
| | --------- Day of the month (1 - 31)
| ----------- Hour (0 - 23)
------------- Minute (0 - 59)
```

Ok so its not that convoluted after all:
The * * * * * would run a script every minute because each of the five fields represents a time unit: 
minutes, hours, days of the month, months, and days of the week. 
An asterisk (*) in a field means "any value", so * * * * * means "every minute".

0 * * * * would be run every hour becuase it specifies that the script should run when the minute field is 0 (i.e., at the beginning of the hour), 
and the other fields are set to *, which means "any value". So this command will run the script once every hour, at the beginning of the hour.

To run a script every 5 min I could do: `*/5 * * * * /path/to/script.sh`
The */5 in the minute field means "every 5 minutes", and the other fields are set to *, which means "any value". 
So this command will run the script once every 5 minutes, at 0, 5, 10, 15, 20, 25, 30, 35, 40, 45, and 50 minutes past the hour.

Note to self: perhaps move this info on cron to another section :)
