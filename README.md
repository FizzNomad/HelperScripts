# HelperScripts
Just little scripts and functions to make my life better.

Covid did a number on my brain so in here you will find little things i've come up with to help me out.

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
