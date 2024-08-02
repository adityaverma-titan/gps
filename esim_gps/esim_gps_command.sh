#!/bin/bash

# URL to hit
URL="https://fitness.mobvoi.com/api/agps?param=%22domain=www.gnss-aide.com;port=2621;user=wjzhou@mobvoi.com;pwd=12mo34bvoi;cmd=eph%22"

# S3 bucket
AWS_BUCKET="s3://twc-pub/gps/61/"

# Temporary file name
TEMP_FILE="agps"

# Log file
LOG_FILE="/root/offline-gps/gps/esim_gps/esimScript.log"

# Start script
echo "$(date '+%Y-%m-%d %H:%M:%S') - Script started" > "$LOG_FILE"

{
    # Download the file
    curl -o $TEMP_FILE $URL
    if [ $? -ne 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to download the file" >&2
        exit 1
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') - File downloaded successfully"

    # Get the current timestamp
    TIMESTAMP=$(date +%s)

    # New file name with timestamp
    NEW_FILE="${TEMP_FILE}_${TIMESTAMP}"

    # Rename the downloaded file
    mv $TEMP_FILE $NEW_FILE
    if [ $? -ne 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to rename the file" >&2
        exit 1
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') - File renamed to $NEW_FILE"

    # Upload the file to the S3 bucket
    aws s3 cp $NEW_FILE $AWS_BUCKET
    if [ $? -ne 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to upload the file to S3" >&2
        exit 1
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') - File uploaded to S3 successfully"

    # Clean up
    rm $NEW_FILE
    if [ $? -ne 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to delete the file" >&2
        exit 1
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') - File deleted successfully"

    # End script
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Script finished successfully"
} >> "$LOG_FILE" 2>&1
