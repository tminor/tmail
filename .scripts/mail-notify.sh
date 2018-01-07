#! /bin/bash
# mail-notify.sh
#
# This script uses notmuch to fetch
#   information that we care about and feeds
#   it to osascript, generating a notification.

# Some variables that fetch interesting stuff
#   that we feed to our notifier.
SEARCH="tag:unread"
# Limit to 1 result since Notification Center sucks.
LIMIT=1
SORT="newest-first"
FROM=$(/usr/local/bin/notmuch search \
			      --format=text \
			      --output=files \
			      --limit="$LIMIT" \
			      --sort="$SORT" "$SEARCH" \
	   | xargs cat | grep "^From:" | sed 's/.*<//' | sed s'/.$//')

# Get the birth date of the latest file so
#  that we can later compare it to the time
#  30 seconds ago.
LATEST=$(/usr/local/bin/notmuch search \
				--format=text \
				--output=files \
				--limit="$LIMIT" \
				--sort="$SORT" "$SEARCH" \
	     | xargs GetFileInfo -d)

# Current time minus 30 seconds.
CURRENT_TIME=$(date -v -30S +%m/%d/%Y\ %H:%M:%S)

# Number of messages tagged as unread.
UNREAD_COUNT=$(/usr/local/bin/notmuch count --output=messages "$SEARCH")

# Use sed magic to extract subject lines.
TXT_SUBS=$(/usr/local/bin/notmuch search \
				  --format=text \
				  --output=summary \
				  --limit="$LIMIT" \
				  --sort="$SORT" "$SEARCH" \
	       | sed 's/^[^;]*; //' | sed 's/$/\n'/)

# Only generate a notification if the most recent message
# was received within the last 30 seconds.
if [[ $CURRENT_TIME < $LATEST ]]; then
  # Check /System/Library/Sounds for available sound name values
  osascript -e 'display notification "'"$TXT_SUBS"'" with title "New mail from '"$FROM"'!" subtitle "You have '"$UNREAD_COUNT"' new messages." sound name "Frog"'
fi
