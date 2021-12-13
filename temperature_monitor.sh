#!/bin/bash
source config_reader.shlib;

SLEEP_PERIOD_S="$(config_get SLEEP_PERIOD_S)"
EMAIL_EVENT_PERIOD_S="$(config_get EMAIL_EVENT_PERIOD_S)"
MAX_ALLOWED_TEMP="$(config_get MAX_ALLOWED_TEMP)"
DESTINATION_EMAIL="$(config_get DESTINATION_EMAIL)"
FROM_EMAIL="$(config_get FROM_EMAIL)"
MAX_LOG_FILE_SIZE="$(config_get MAX_LOG_FILE_SIZE)" #Default max file size is 1 MB

LOG_DIR="$(config_get LOG_DIR)"
LOG_PATH="$(config_get LOG_PATH)"
TEMP_DIR_PATH="$(config_get TEMP_DIR_PATH)"
EMAIL_BODY_PATH="$(config_get EMAIL_BODY_PATH)"

sendMail(){
#create necessary folder if not exists
    #mkdir -p $TEMP_DIR_PATH     
#clear file content
    #> $EMAIL_BODY_PATH
#write new content
    #echo $1 >> $EMAIL_BODY_PATH

    echo -e "Subject:$1 \n\n $2" | sendmail -f $FROM_EMAIL $DESTINATION_EMAIL
    
    log "Email Sent to ${DESTINATION_EMAIL}"
}

log(){
	#create log dir if not existing
	if [ ! -d "$LOG_DIR" ]; then
	  log "Creating log dir ${LOG_DIR}..."
	  mkdir  "$LOG_DIR"
	fi
    currentTimeStamp=$(date)
    echo -e "${currentTimeStamp}: $1" >> $LOG_PATH
    echo -e "${currentTimeStamp}: $1"
    #printf "%s" "$1"
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

