#!/bin/bash
# Utilities
jval() {
	local list=$(echo $@ | sed 's/ /,/g')
	cat | egrep "\\[$list\\]"
}

lval() {
	cat | awk -v ORS=" " '{for (i=2; i<=NF; i++) print $i;}' \
		| awk '{gsub(/^ +| +$/,"")} {print $0}' \
		| sed -e 's/^"\(.*\)"$/\1/'
}

val() {
	jval $@ | lval | sed 's@\\/@/@g; s@\\"@"@g'
}

monitor_subshell() {
	sleep $TIMEOUT
	kill $1 &> /dev/null
}

parse_msg() {
	local u="$(cat)"
	msg_chat_id=$(echo "$u" | val '"message"' '"chat"' '"id"')
	msg_from_id=$(echo "$u" | val '"message"' '"from"' '"id"')
	msg_from_username=$(echo "$u" | val '"message"' '"from"' '"username"')
	msg_text="$(echo "$u" | val '"message"' '"text"')"
	msg_id=$(echo "$u" | val '"message"' '"message_id"')
}

# Temporary storage for statuses
# Making use of Tmpfs
TMPDIR="/tmp/bashbot"
status_create() {
	mkdir -p "$TMPDIR/$1/$2/"
}

# After registering, redirect all the input messages to command $3
status_catch() {
	status_create $1 $2
	echo "$3" > "$TMPDIR/$1/$2/default"
}

status_put() {
	status_create $1 $2
	echo "$4" > "$TMPDIR/$1/$2/$3"
}

status_get() {
	cat "$TMPDIR/$1/$2/$3"
}

# Clean things up
status_release() {
	rm -rf "$TMPDIR/$1/$2"
}
