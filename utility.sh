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
