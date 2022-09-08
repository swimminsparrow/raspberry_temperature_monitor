#!/bin/bash
CONFIG_DIR=$HOME/.config/raspberry_temperature_monitor
CONFIG_FILE_DEFAULT=$CONFIG_DIR/config.cfg.defaults
CONFIG_FILE_CUSTOM=$CONFIG_DIR/config.cfg
SERVICE_FILE=/etc/systemd/system/temperature_monitor.service

# Bold Colors
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White
NC='\033[0m'              # No Color

# $1:message
# $2:log arguments (Default: only "e")
# $3:color (Default: shell text color)
log(){
    if [ -z "$3" ] ; then
        echo -e"${2}" "${1}"
    else 
        echo -e"${2}" "${3}${1}${NC}"
    fi
}

log "Installing Dependencies..."
sudo apt install bc sendmail -y
log "Checking if default configurations exists"
mkdir -p $CONFIG_DIR
cp "./config.cfg.defaults" $CONFIG_FILE_DEFAULT

if test -f "$CONFIG_FILE_CUSTOM"; then
    log "$CONFIG_FILE_CUSTOM already exists. Skipping creation..."
else
    log "Creating $CONFIG_FILE_CUSTOM from defaults"
    cp $CONFIG_FILE_DEFAULT $CONFIG_FILE_CUSTOM
fi

log "You have to edit the configurations in the editor. Are u ready? (Type 1 or 2)"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit;;
    esac
done

nano $CONFIG_FILE_CUSTOM

log "Copying bin and service Files"
sudo cp temperature_monitor.sh /usr/bin/temperature_monitor.sh
sudo chmod +x /usr/bin/temperature_monitor.sh

if test -f "$SERVICE_FILE"; then
    log "Service file $SERVICE_FILE already exists. Skipping creation..."
else
    log "Copying service file to $SERVICE_FILE"
    sudo cp install_files/temperature_monitor.service $SERVICE_FILE
fi

log "You will edit the HOME_DIR variable in the editor if you are installing the tool for the first time. Are u ready? (Type 1 or 2)"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit;;
    esac
done

sudo nano $SERVICE_FILE 
sudo chmod 644 $SERVICE_FILE

service_status=$(systemctl show -p SubState --value temperature_monitor)

if [[ "$service_status" == "running" ]]; then
    log "Service is already running! Restarting after update..."
    sudo systemctl restart temperature_monitor
else
    log "Enabling Service"
    sudo systemctl enable temperature_monitor
    log "Starting Service"
    sudo systemctl start temperature_monitor
fi

service_status=$(systemctl show -p SubState --value temperature_monitor)
log "Checking Everything is ok...Service " "n"
if [[ "$service_status" == "running" ]]; then
    log "$service_status" "" "${BGreen}"
else
    log "$service_status" "" "${BRed}"
fi

log "Can get more info typing 'sudo systemctl status temperature_monitor'"

