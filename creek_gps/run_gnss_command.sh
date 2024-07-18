#!/bin/bash

LOGFILE="/path/to/logfile.log"
exec > >(tee -a $LOGFILE) 2>&1

echo "Starting script at $(date)"

# Define variables
SOURCE_BUCKET="s3://twcd-images/offline_gps/gnss"
DESTINATION_BUCKET="s3://twcd-images/gps/81"
OUTPUT_FOLDER="gnss_out"
OUTPUT_FILE="rtcm_all.gnss"
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
LOCAL_COMMAND="./RXN_IntApp"

# Step 1: Download the command from the S3 bucket
echo "Downloading command from S3 bucket..."
aws s3 cp $SOURCE_BUCKET/$LOCAL_COMMAND .

# Step 2: Make the command executable
chmod +x $LOCAL_COMMAND

# Step 3: Run the command with sudo
echo "Running the command with sudo..."
sudo $LOCAL_COMMAND

# Step 4: Copy the output file to the destination S3 bucket with a timestamp
if [ -f "$OUTPUT_FOLDER/$OUTPUT_FILE" ]; then
    NEW_FILE_NAME="${OUTPUT_FILE%.*}_$TIMESTAMP.${OUTPUT_FILE##*.}"
    echo "Uploading output file to S3 bucket with new name: $NEW_FILE_NAME"
    aws s3 cp "$OUTPUT_FOLDER/$OUTPUT_FILE" "$DESTINATION_BUCKET/$NEW_FILE_NAME"
else
    echo "Output file not found."
    exit 1
fi

echo "Script completed at $(date)"
