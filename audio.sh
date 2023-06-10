#!/bin/bash

# Name of two audio devices with the same name
device_name="INZONE H9 / INZONE H7"
# Maximum number of attempts
max_attempts=5

# Delay between each attempt (in seconds)
delay=2

# Function to run the command and extract object IDs
run_command() {
  pw-dump | grep -A 10 -P "\"node.nick\": \"$device_name\"" | grep -oP "\"object.id\": \K\d+"
}

# Attempt to run the command multiple times with delay
for ((attempt = 1; attempt <= max_attempts; attempt++)); do
  # Delay before each attempt
  sleep $delay

  # Run the command and extract the object IDs
  object_ids=$(run_command)

  # Check if any object IDs were found
  if [ -n "$object_ids" ]; then
    # Convert the object IDs into an array
    object_ids_array=($object_ids)

    # Find the highest and least IDs
    highest_id=${object_ids_array[0]}
    least_id=${object_ids_array[2]}
    if [ "$highest_id" -lt "$least_id" ]; then
      temp=$highest_id
      highest_id=$least_id
      least_id=$temp
    fi

    pw-link "$highest_id" "$least_id"
    # Print the object IDs
    echo "Found object IDs: ${object_ids_array[*]}"
    break
  fi

  # If no object IDs were found, display failure message
  echo "No matching object IDs found. Attempt: $attempt/$max_attempts"
done

