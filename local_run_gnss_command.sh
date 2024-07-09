#!/bin/bash

LOGFILE="/home/shivani/gps/logfile.log"
WORKING_DIR="/home/shivani/gps"
OUTPUT_FOLDER="$WORKING_DIR/gnss_out"
OUTPUT_FILE="rtcm_all.gnss"
LOCAL_COMMAND="$WORKING_DIR/RXN_IntApp"
CONFIG_FILE="$WORKING_DIR/MSLConfig.txt"
AWS_BUCKET="s3://twcd-images/gps/81/"

{
    echo "Starting script at $(date)"

    # Step 1: Ensure the command is executable
    echo "Making the command executable..."
    sudo chmod +x "$LOCAL_COMMAND"

    # Step 2: Run the command with sudo, specifying the config file
    echo "Running the command with sudo..."
    sudo "$LOCAL_COMMAND" "$CONFIG_FILE"

    # Step 3: Copy the latest output file to the working directory
    if [ -f "$OUTPUT_FOLDER/$OUTPUT_FILE" ]; then
        echo "Updating output file in working directory..."
        cp "$OUTPUT_FOLDER/$OUTPUT_FILE" "$WORKING_DIR/$OUTPUT_FILE"
    else
        echo "Output file not found."
        exit 1
    fi

    # Step 4: Add timestamp to filename
    TIMESTAMP=$(date +"%Y%m%d%H%M%S")
    NEW_FILE_NAME="${OUTPUT_FILE%.*}_$TIMESTAMP.${OUTPUT_FILE##*.}"
    mv "$WORKING_DIR/$OUTPUT_FILE" "$WORKING_DIR/$NEW_FILE_NAME"

    # Step 5: Upload the updated file with timestamp to AWS S3
    echo "Uploading file to AWS S3..."
    aws s3 cp "$WORKING_DIR/$NEW_FILE_NAME" "$AWS_BUCKET"

    echo "Script completed at $(date)"
} >> "$LOGFILE" 2>&1
