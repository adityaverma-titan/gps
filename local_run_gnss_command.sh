#!/bin/bash

LOGFILE="/home/shivani/gps/logfile.log"
WORKING_DIR="/home/shivani/gps"
OUTPUT_FOLDER="$WORKING_DIR/gnss_out"
OUTPUT_FILE="rtcm_all.agnss"
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

    # Step 6: Cleanup: Keep only the latest 5 files and delete the rest
	
	# Ensure we are in the working directory
	cd "$WORKING_DIR" || exit 1

	# Debugging: List files to check if they exist
	ls -l rtcm_all*.agnss

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
   
>> "$LOGFILE" 2>&1