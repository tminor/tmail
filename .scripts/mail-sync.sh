#! /bin/bash
# mail-sync.sh
#
# Schedule this script with cron or something similar
#    to automatically fetch mail, populate the notmuch
#    database and trigger notifications.

# Specify the path to a log file.
LOG_FILE="/Users/$(id -un)/.log/mail.log"
# I found it necessary to ensure to specify $PATH 
# when running this script on OS X.
PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin/"
# Enable logging if things get weird.
LOGGING_ENABLED=false
# Path to your mail notify script.
MAIL_NOTIFY="/Users/$(id -un)/.scripts/mail-notify.sh"

if [ $LOGGING_ENABLED = true ]; then
  echo "$(date): PATH is $PATH" >> $LOG_FILE
  printf "\n" >> $LOG_FILE

  # Sync mail
  echo '### mbsync output and exit status ###' >> $LOG_FILE
  printf "\n" >> $LOG_FILE
  /usr/local/bin/mbsync -a >> $LOG_FILE 2>&1
  echo "$(date): mbsync exited with status $?" >> $LOG_FILE
  printf "\n" >> $LOG_FILE

  # Tag new mail with 'new'
  echo '### notmuch output and exit status ###' >> $LOG_FILE
  printf "\n" >> $LOG_FILE
  /usr/local/bin/notmuch new >> $LOG_FILE 2>&1
  echo "$(date): notmuch exited with status $?" >> $LOG_FILE
  printf "\n" >> $LOG_FILE

  # Tag qualifying 'new' mail with 'spam'
  echo '### bogofilter script output ###'
  printf "\n" >> $LOG_FILE
  /usr/local/bin/python3 /Users/tminor/.scripts/spam-filter.py >> $LOG_FILE 2>&1
  echo "$(date): spam-filter.py exited with status $?" >> $LOG_FILE
  printf "\n" >> $LOG_FILE

  # Filter with afew
  echo '### afew output and exit status ###' >> $LOG_FILE
  printf "\n" >> $LOG_FILE
  /Users/tminor/.venv/bin/afew --tag --new -vv >> $LOG_FILE 2>&1
  echo "$(date): afew exited with status $?" >> $LOG_FILE
  printf "\n" >> $LOG_FILE

  # Finally, notify of new mail
  echo '### mail-notify.sh output and exit status ###' >> $LOG_FILE
  printf "\n" >> $LOG_FILE
  /bin/bash $MAIL_NOTIFY >> $LOG_FILE 2>&1
  echo "$(date): mail-notify.sh exited with status $?" >> $LOG_FILE
  printf "\n" >> $LOG_FILE
else
  /usr/local/bin/mbsync -a
  /usr/local/bin/notmuch new
  /Users/tminor/.venv/bin/afew --tag --new
  /usr/local/bin/python3 /Users/tminor/.scripts/spam-filter.py
  /bin/bash $MAIL_NOTIFY
fi

# TODO
# -------
# Make logging output more palatable.
#
# Create a function for logging output.
