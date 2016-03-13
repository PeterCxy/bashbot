#!/bin/bash
# A simple wrapper for Googler
# This depends on Python 2 / 3
command 'google' cmd_google '''
/google query: Google for [query]
Only one result is shown each time.
Call /google without the [query] argument to get one more result of the last query.
'''

GOOGLER="./libs/googler/googler"

cmd_google() {
	parse_msg
	local query="$@"
	local start=0
	if [[ -z "$query" ]]; then
		query="$(status_get $msg_chat_id $msg_from_id 'google_query')"
		start="$(status_get $msg_chat_id $msg_from_id 'google_start')"
		[[ -z "$query" ]] && return 0
		start+=1
	fi

	status_put $msg_chat_id $msg_from_id 'google_query' "$query"
	status_put $msg_chat_id $msg_from_id 'google_start' "$start"
	local res="$($GOOGLER -C -c uk -x -n 1 -s $start "$query" < /dev/null)"
	res="$(echo "$res" | sed 's/Enter n, p, result number or new keywords://g')"
	
	[[ -z "$(echo "$res" | xargs)" ]] && res="(@_@) Nothing found."

	api_sendMessage \
		-d "chat_id=$msg_chat_id" \
		-d "reply_to_message_id=$msg_id" \
		-d "text=$res" \
		> /dev/null
}
