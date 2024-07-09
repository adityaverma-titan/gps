#!/bin/bash

LOGFILE="/home/shivani/gps/logfile.log"

{
    echo "Starting script at $(date)"

    # Define variables
    WORKING_DIR="/home/shivani/gps"
    OUTPUT_FOLDER="$WORKING_DIR/gnss_out"
    OUTPUT_FILE="rtcm_all.gnss"
    TIMESTAMP=$(date +"%Y%m%d%H%M%S")
    LOCAL_COMMAND="$WORKING_DIR/RXN_IntApp"
    CONFIG_FILE="$WORKING_DIR/MSLConfig.txt"

    # Change to the working directory
    cd "$WORKING_DIR" || { echo "Failed to change directory to $WORKING_DIR"; exit 1; }

    # Step 1: Ensure the command is executable
    echo "Making the command executable..."
    sudo chmod +x "$LOCAL_COMMAND"

    # Step 2: Run the command with sudo, specifying the config file
    echo "Running the command with sudo..."
    sudo "$LOCAL_COMMAND" "$CONFIG_FILE"

    # Step 3: Copy the output file to the same directory with a timestamp
    if [ -f "$OUTPUT_FOLDER/$OUTPUT_FILE" ]; then
        NEW_FILE_NAME="${OUTPUT_FILE%.*}_$TIMESTAMP.${OUTPUT_FILE##*.}"
        echo "Saving output file with new name: $NEW_FILE_NAME"
        cp "$OUTPUT_FOLDER/$OUTPUT_FILE" "$WORKING_DIR/${NEW_FILE_NAME##*/}"
    else
        echo "Output file not found."
        exit 1
    fi

    echo "Script completed at $(date)"
} >> "$LOGFILE" 2>&1
