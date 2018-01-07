# spam-filter.py
#
# This script uses bogofilter to classify spam.
#
# TODO
# -----
# Need more error handling.
#
# Use filepath attribute to log messages classified as spam.

import subprocess
import notmuch
import sys
import os

# Some handy variables.

db = notmuch.Database(mode=1)
query = db.create_query('tag:new')
bogofilter = '/usr/local/bin/bogofilter'

# Define a class that we'll use to store a file path
# and bogofilter spam classification.

class pOutput(object):
    path = ""
    mailType = ""

# Function for instantiating a bogofilter object.

def processOutput(path, mailType):
    processed = pOutput()
    processed.path = path
    processed.mailType = mailType
    return processed

def isSpam(path):
    # Run bogofilter.
    p = subprocess.run(['bogofilter', "-BT", path], stdout=subprocess.PIPE)
    # Decode its output.
    output = p.stdout.decode('ascii')
    # Split the output into a list for indexing.
    output = output.split(" ")
    # Assign index 0 (file path) to the path attribute.
    # Assign index 1 (H, U, or S classification) to mailType attribute.
    processed = processOutput(output[0], output[1])
    # If mail is U or H, the message is not spam. Otherwise, it's spam.
    if processed.mailType == 'U' or processed.mailType == 'H':
        return False
    if processed.mailType == 'S':
        return True

# Query the notmuch DB with 'tag:new', iterate over all of the matches,
# and use isSpam to return whether or not the resulting message is spam.

for msg in query.search_messages():
    for filepath in msg.get_filenames():
        if isSpam(filepath) == True:
            msg.remove_tag('new')
            msg.add_tag('spam')
        if isSpam(filepath) == False:
            msg.remove_tag('new')
            msg.add_tag('inbox')

sys.exit()
