#!/bin/bash

WORKING_DIR="/home/shivani/gps"
FILE_LIST=$(ls -t "$WORKING_DIR/rtcm_all*.agnss" 2>/dev/null)

echo "Files found for cleanup:"
echo "$FILE_LIST"

# Check if there are more than 5 files and delete older ones
NUM_FILES=$(echo "$FILE_LIST" | wc -l)
if [ "$NUM_FILES" -gt 5 ]; then
    FILES_TO_DELETE=$(echo "$FILE_LIST" | tail -n +6)
    echo "Files to delete:"
    echo "$FILES_TO_DELETE"
    echo "Deleting files..."
    rm $FILES_TO_DELETE
else
    echo "No files to delete."
fi
