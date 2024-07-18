#!/bin/bash

LOGFILE="/home/shivani/gps/creek_gps/logfile.log"
WORKING_DIR="/home/shivani/gps/creek_gps"
OUTPUT_FOLDER="$WORKING_DIR/gnss_out"
OUTPUT_FILE="rtcm_all.agnss"
LOCAL_COMMAND="$WORKING_DIR/RXN_IntApp"
CONFIG_FILE="/home/shivani/gps/creek_gps/MSLConfig.txt"
AWS_BUCKET="s3://twcd-images/gps/TITAN_90206/"

{
    echo "Starting script at $(date)"
    cd "$WORKING_DIR" || exit 1

    # Step 1: Ensure the command is executable
    echo "Making the command executable..."
    sudo chmod +x "$LOCAL_COMMAND"

    # Check if configuration file exists and is readable
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Configuration file not found: $CONFIG_FILE"
        exit 1
    fi
    if [ ! -r "$CONFIG_FILE" ]; then
        echo "Configuration file is not readable: $CONFIG_FILE"
        sudo chmod 644 "$CONFIG_FILE"
    fi

    # Step 3: Run the command with sudo, specifying the config file
    sudo "$LOCAL_COMMAND" "$CONFIG_FILE"
    COMMAND_EXIT_CODE=$?
    if [ $COMMAND_EXIT_CODE -ne 0 ]; then
        echo "Error running command with configuration file. Exit code: $COMMAND_EXIT_CODE"
        exit 1
    fi

    # Step 2: Run the command with sudo, specifying the config file
    sudo "$LOCAL_COMMAND" "$CONFIG_FILE"
    if [ $? -ne 0 ]; then
        echo "Error running command with configuration file."
        exit 1
    fi

    # Step 3: Copy the latest output file to the working directory
    if [ -f "$OUTPUT_FOLDER/$OUTPUT_FILE" ]; then
        cp "$OUTPUT_FOLDER/$OUTPUT_FILE" "$WORKING_DIR/$OUTPUT_FILE"
    else
        echo "Output file not found."
        exit 1
    fi
	
	# Step 4: Add epoch timestamp to filename
    EPOCH_TIMESTAMP=$(date +"%s")
    NEW_FILE_NAME="${OUTPUT_FILE%.*}_$EPOCH_TIMESTAMP.${OUTPUT_FILE##*.}"
    mv "$WORKING_DIR/$OUTPUT_FILE" "$WORKING_DIR/$NEW_FILE_NAME"

    # Step 5: Upload the updated file with timestamp to AWS S3
    aws s3 cp "$WORKING_DIR/$NEW_FILE_NAME" "$AWS_BUCKET"

    # Step 6: Cleanup: Keep only the latest 5 files and delete the rest
    # Ensure we are in the working directory
    #cd "$WORKING_DIR" || exit 1

    # Delete older files, keeping the latest 5
    FILE_LIST=$(ls -t rtcm_all*.agnss 2>/dev/null)
	COUNT=0

    # Loop through the files and keep track of how many we've processed
    for FILE in $FILE_LIST; do
		if [ $COUNT -ge 5 ]; then
			echo "Deleting $FILE"
			rm "$FILE"
        else
			echo "Keeping $FILE"
        fi
			COUNT=$((COUNT + 1))
        done

    echo "Script completed at $(date)"
} >> "$LOGFILE" 2>&1