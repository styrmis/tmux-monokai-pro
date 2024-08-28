#!/usr/bin/env bash

strip_trailing_whitespace() {
  local input_string="$1"
  # Using parameter expansion to remove trailing whitespace
  local stripped_string="${input_string%"${input_string##*[![:space:]]}"}"
  echo "$stripped_string"
}

# Get the current date in YYYY-MM-DD format
current_date=$(date "+%Y-%m-%d")

current_event=$(/opt/homebrew/bin/icalBuddy -b "" -npn -nc -iep "title" -eed -li 1 -ic "$1" eventsNow)
next_event=$(/opt/homebrew/bin/icalBuddy -n -b "" -npn -nc -ps "/ » /" -iep "title,datetime" -eed -li 1 -ic "$1" eventsToday)

if [ -n "$current_event" ]; then
  echo "$current_event"
elif [ -n "$next_event" ]; then
  # Extract the time (24-hour format) of the next event
  title=$(echo "$next_event" | cut -d» -f 1)  # Assuming the format is "Date Time"
  event_time=$(echo "$next_event" | cut -d» -f 2)  # Assuming the format is "Date Time"

  # Combine current date with event time
  event_datetime="${current_date} ${event_time}"

  # Convert to timestamp
  event_timestamp=$(date -j -f "%Y-%m-%d %H:%M" "$event_datetime" "+%s")
  current_timestamp=$(date "+%s")

  # Calculate the difference in seconds
  diff_seconds=$((event_timestamp - current_timestamp))

  if [ $diff_seconds -gt 0 ]; then
    # Convert seconds to hours and minutes
    hours=$((diff_seconds / 3600))
    minutes=$(((diff_seconds % 3600) / 60))

    echo $(strip_trailing_whitespace "$title » ${hours}h${minutes}m")
  else
    echo $(strip_trailing_whitespace "$title [now]")
  fi
fi
