#!/bin/bash
# The /help command
command 'help' cmd_help '/help command - Get help with [command]'

cmd_help() {
	parse_msg
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
		-d "chat_id=$msg_chat_id" \
		-d "reply_to_message_id=$msg_id" \
		> /dev/null
}
