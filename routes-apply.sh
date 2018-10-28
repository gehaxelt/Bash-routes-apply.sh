#!/bin/bash
# Author: Sebastian Neef (@gehaxelt)
# License: MIT
# Source: https://github.com/gehaxelt/Bash-routes-apply.sh

IPBINARY=/usr/bin/ip
TMPFILE=`mktemp /tmp/routes-apply-XXXXXXXX`
TIMEOUT=30

# Check root rights
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root!" 
   exit 1
fi


# Check if given file exists
if [[ ! -f "$1" ]]; then
   echo "No file with routes given or $1 does not exist!" 
   exit 1
fi

echo "[*] Current routes are:"
echo
"$IPBINARY" route show
echo
# Save routes to temp file
echo "[*] Saving current routes to $TMPFILE"
"$IPBINARY" route save > "$TMPFILE"

echo "[*] Applying route commands from $1"
echo 
cat "$1" | while read CMD; do
   eval "(set -x;" "$IPBINARY" route "$CMD" ")";
done

echo 
echo "[*] The routes are now:"
echo
"$IPBINARY" route show
echo
# Prompt user for confirmation
echo -n "[*] Packets still flowing and is the connection alive? (y/N) "

read -n1 -t "$TIMEOUT" ret 2>&1 || :
echo 
case "${ret:-}" in
    (y*|Y*)
        # Success
         echo "[*] The routes are now:"
	       echo
        "$IPBINARY" route show
        exit 0
        ;;
    (*)
        # Failed
        echo "[*] No answer, restoring routes!"
        "$IPBINARY" route flush root 0/0
        "$IPBINARY" route restore < "$TMPFILE"
        rm "$TMPFILE"
        echo "[*] The routes are now:"
        echo
        "$IPBINARY" route show
        exit 255
        ;;
esac

