Simple Temperature Monitor Service for your raspberry pi. Sends a email when the max specified temperature is reached. 

## Requirements

- "vcgencmd measure_temp" command working on your OS running on Raspberry Pi



## Installation

The installation script will install temperature monitor as a service running in background and starting automatically on system boot.

```bash
sudo chmod +x install.sh
./install.sh
```

The installation will prompt some questions to correctly configure the script. During the installation you will be asked to type the destination email address for the notifications.

Check everything ok after the installation.

```bash
sudo systemctl status temperature_monitor
```



## One Time Execution

You can also run the script manually.

```bash
sudo chmod +x temperature_monitor.sh
sudo temperature_monitor.sh -c $HOME/.config/raspberry_temperature_monitor
```



