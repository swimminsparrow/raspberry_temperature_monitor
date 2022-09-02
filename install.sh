#!/bin/bash
CONFIG_DIR=$HOME/.config/raspberry_temperature_monitor
CONFIG_FILE_DEFAULT=$CONFIG_DIR/config.cfg.defaults
CONFIG_FILE_CUSTOM=$CONFIG_DIR/config.cfg

echo "Installing Dependencies..."
sudo apt install bc sendmail -y
echo "Checking if default configurations exists"
mkdir -p $CONFIG_DIR
cp "./config.cfg.defaults" $CONFIG_FILE_DEFAULT

if test -f "$CONFIG_FILE_CUSTOM"; then
    echo "$CONFIG_FILE_CUSTOM already exists. Skipping creation..."
else
    echo "Creating $CONFIG_FILE_CUSTOM from defaults"
    cp $CONFIG_FILE_DEFAULT $CONFIG_FILE_CUSTOM
fi

echo "You have to edit the configurations in the editor. Are u ready? (Type 1 or 2)"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit;;
    esac
done

nano $CONFIG_FILE_CUSTOM

echo "Copying bin and service Files"
sudo cp temperature_monitor.sh /usr/bin/temperature_monitor.sh
sudo chmod +x /usr/bin/temperature_monitor.sh
sudo cp install_files/temperature_monitor.service /etc/systemd/system/temperature_monitor.service


echo "You will edit the HOME_DIR variable in the editor. Are u ready? (Type 1 or 2)"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit;;
    esac
done

sudo nano /etc/systemd/system/temperature_monitor.service 
sudo chmod 644 /etc/systemd/system/temperature_monitor.service
echo "Enabling Service"
sudo systemctl enable temperature_monitor
echo "Starting Service"
sudo systemctl start temperature_monitor
echo "Checking Everything is ok"
sudo systemctl status temperature_monitor
