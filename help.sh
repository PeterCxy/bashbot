#!/bin/bash
# The /help command
command 'help' cmd_help '/help command - Get help with [command]'

cmd_help() {
	local u="$(cat)"
	local cmd=$1
	if [[ -z "$cmd" ]]; then
		cmd="help"
	fi
	local h="${HELPS[$cmd]}"
	if [[ -z "$h" ]]; then
		h="Help for $cmd not found"
	fi
	api_sendMessage \
		-d "text=$h" \
		-d "chat_id=$(echo "$u" | val '"message"' '"chat"' '"id"')" \
		-d "reply_to_message_id=$(echo "$u" | val '"message"' '"message_id"')" \
		> /dev/null
}
