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



## Configure Email or Telegram Event

The script is capable to send an email or a telegram message if the max temperature has been reached. The settings are available in $HOME/.config/raspberry_temperature_monitor/config.cfg:

```bash
DESTINATION_EMAIL=
FROM_EMAIL=
TELEGRAM_API_KEY=
TELEGRAM_CHAT_ID=
```

Check this to get an api key for telegram https://my.telegram.org/auth?to=apps and this https://stackoverflow.com/questions/31078710/how-to-obtain-telegram-chat-id-for-a-specific-user/37396871#37396871 to get the Chat id of your bot. 



## One Time Execution

You can also run the script manually.

```bash
sudo chmod +x temperature_monitor.sh
sudo temperature_monitor.sh -c $HOME/.config/raspberry_temperature_monitor -v
```



