#!/bin/bash

CONFIG_DIR=$HOME/.config/raspberry_temperature_monitor
VERBOSE=false

############################################################
# Help                                                     #
############################################################
Help() {
   echo "Simple Script for monitoring temperature in your raspberry pi. Sends a email when a max temperature is reached."
   echo
   echo "Syntax: temperature_monitor [-c|h]"
   echo "options:"
   echo "-c [CONFIG_DIR_PATH]        Config file to read"
   echo "-v                          Enable Verbose Logging"
   echo "-h                          Print this Help."
   echo
}

############################################################
# Load Configs                                             #
############################################################
load_configs() {
    if [ ! -d "$CONFIG_DIR" ]; then
	  echo -e "Config dir ${CONFIG_DIR} does not exists!"
	  exit -1;
	fi
    if test -f "$CONFIG_DIR/config.cfg.defaults"; then
        echo -e "Loading Configs from ${CONFIG_DIR}/config.cfg.defaults"
        source $CONFIG_DIR/config.cfg.defaults
    fi
    if test -f "$CONFIG_DIR/config.cfg"; then
        echo -e "Loading Configs from ${CONFIG_DIR}/config.cfg"
        source $CONFIG_DIR/config.cfg
    fi
}
############################################################
# Parse CLI arguments                                      #
############################################################
while getopts ":hc:" option; do
    case $option in
       h) # Display help message
            Help
            exit;;
       c) # Config dir
            CONFIG_DIR=$OPTARG
            load_configs;;
       v) # Verbose logging
            VERBOSE=true;;
      \?) # Invalid option
            echo "Error: Invalid option"
            exit;;
    esac
done

sendMail(){

    echo -e "Subject:$1 \n\n $2" | sendmail -f $FROM_EMAIL $DESTINATION_EMAIL
    
    log "Email Sent to ${DESTINATION_EMAIL}"
}

log(){
	#create log dir if not existing
	if [ ! -d "$LOG_DIR" ]; then
	  echo -e "Creating log dir ${LOG_DIR}..."
	  mkdir -p "$LOG_DIR"
	fi
    currentTimeStamp=$(date)
    echo -e "${currentTimeStamp}: $1" >> $LOG_PATH
    if [ "$VERBOSE" = true ] ; then
        echo -e "${currentTimeStamp}: $1"
    fi    
}

archiveLogFileIfNecessary(){
    fileSize=$(wc -c "$LOG_PATH" | awk '{print $1}')
    if [ $(echo "$fileSize > $MAX_LOG_FILE_SIZE" | bc) -ne 0 ]
    then
        IS_AVAILABLE_FILE_NAME_INDEX=0
        i=1

        log "Log File size is ${fileSize} (MAX_LOG_FILE_SIZE=${MAX_LOG_FILE_SIZE}). Archiving previous log file..."

        while test $IS_AVAILABLE_FILE_NAME_INDEX -eq 0;
        do
            ARCHIVED_LOG_FILEPATH="${LOG_PATH}.${i}"
            #echo $ARCHIVED_LOG_FILEPATH
            if test -f "$ARCHIVED_LOG_FILEPATH"
            then
                i=$((i + 1))
            else
                mv $LOG_PATH $ARCHIVED_LOG_FILEPATH
                log "New File has been saved as ${ARCHIVED_LOG_FILEPATH}"
                IS_AVAILABLE_FILE_NAME_INDEX=1
            fi
        done
    fi
}

main(){
    secondsFromLastMailEvent=-1

    log "Temperature Monitor service started"

    while true
    do
        temperature=$(vcgencmd measure_temp | egrep -o '[0-9]*\.[0-9]*')
        currentTimeStamp=$(date)

        if [ $(echo "$temperature < $MAX_ALLOWED_TEMP" | bc) -ne 0 ]
        then
            log "Temperature is ${temperature} Celsius Degrees"
        else

            log "WARNING! Temperature is ${temperature} Celsius Degrees"

            #Check if i can send a new mail event
            if [ $(bc <<< "$secondsFromLastMailEvent >= $EMAIL_EVENT_PERIOD_S  || $secondsFromLastMailEvent == -1")  ]      
            then
                log "${secondsFromLastMailEvent} seconds passed from last email event. An alert email will be sent"
                
                subject=$"Raspberry Temperature is ${temperature}"
                mailBody=$"WARNING! Temperature too high on raspberry pi!\nDATE: ${currentTimeStamp}\nTEMPERATURE: ${temperature} Celsius Degrees"
                sendMail "$subject" "$mailBody"  
                secondsFromLastMailEvent=0
            else
                log "${secondsFromLastMailEvent} seconds passed from last email event. Waiting for next event if temperature is not freezing..."
            fi
        
        fi    

        archiveLogFileIfNecessary

        sleep $SLEEP_PERIOD_S
        
        # Last email time counter should be incremented only in certain conditions
        if [ $(echo "$secondsFromLastMailEvent >= 0 " | bc) -ne 0 ]
            then
                secondsFromLastMailEvent=$((secondsFromLastMailEvent+SLEEP_PERIOD_S))
        fi
    done
}


main
