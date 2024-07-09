#!/bin/bash

LOGFILE="/home/shivani/gps/logfileaws.log"
S3_BUCKET="s3://twcd-images/gps/81/"
NUM_TO_KEEP=5

{
	echo "Old files deleting from S3."
	
	# List objects in the S3 bucket
	aws s3 ls "$S3_BUCKET" --recursive | \
	  awk '{print $4, $1, $2}' | \  # Extract file name, date, and time 
	  sort -r -k3 | \   # Sort by the date and time in reverse order 
	  tail -n +$((NUM_TO_KEEP+1)) | \  # Displays all the files except the latest $NUM_TO_KEEP 
	  while read obj _ _; do
		if [ -n "$obj" ]; then
		  echo "Deleting old file: $obj"
		  aws s3 rm "$S3_BUCKET$obj"
		fi
	  done

	echo "Old files deleted from S3."
} >> "$LOGFILE" 2>&1