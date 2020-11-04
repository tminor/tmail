#! /bin/bash

vpn_status=$(nmcli connection show vpn | \
	       grep -i vpn.vpn-state | \
	       awk '{print $5}')

if [[ $vpn_status =~ "connected" ]]; then
  /usr/local/bin/muchsync -v example.com -v
  /usr/bin/emacsclient -e '(tm/notmuch-notify "3mins")'
fi

exit 0
