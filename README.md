Simple Script for monitoring temperature in your raspberry pi. Sends a email when a max temperature is reached. 

You can use it also as a service.



## Requirements

```bash
sudo apt install bc sendmail
```

Create Configs

```bash
mkdir $HOME/.config/temperature_monitor/
mv config.cfg.defaults $HOME/.config/temperature_monitor/
```

Create a custom config file

```bash
sudo nano $HOME/.config/temperature_monitor/config.cfg
```

With the following content

```bash
#Destionation mail address to send alerts
DESTINATION_EMAIL=
#Sender email ex: raspberry@localdomain
FROM_EMAIL=
```



## One Time Execution

```bash
sudo chmod +x temperature_monitor.sh
sudo temperature_monitor.sh -c $HOME/.config/raspberry_temperature_monitor
```



## Keep Running as a Background Service

Give permissions

```bash
sudo cp temperature_monitor.sh /usr/bin/temperature_monitor.sh
sudo chmod +x /usr/bin/temperature_monitor.sh
```

Create a Service

```bash
sudo nano /etc/systemd/system/temperature_monitor.service
```

Type the Content  (Replace CONFIG_DIR_PATH with the path to the config directory)

```bash
[Unit]
Description=Temperature Monitor Service.

[Service]
Type=simple
Environment="CONFIG_DIR=-c CONFIG_DIR_PATH"
ExecStart=/bin/bash /usr/bin/temperature_monitor.sh $CONFIG_DIR

[Install]
WantedBy=multi-user.target
```

Set Permissions to the System Service

```bash
sudo chmod 644 /etc/systemd/system/temperature_monitor.service
```

Enable and start the service

```bash
sudo systemctl enable temperature_monitor
sudo systemctl start temperature_monitor
```

Check everything ok

```bash
sudo systemctl status temperature_monitor
```

