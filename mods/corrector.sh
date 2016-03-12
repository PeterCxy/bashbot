#!/bin/bash
# s/A/B support in chats
default def_correct

def_correct() {
	parse_msg
	if [[ "$msg_text" =~ ^s/.*/.*/g?i?$ ]]; then
		local last="$(status_get $msg_chat_id $msg_from_id 'last')"
		[[ -z "$last" ]] && return 0
		last="$(echo "$last" | sed "$msg_text")"
		api_sendMessage \
			-d "chat_id=$msg_chat_id" \
			-d "text=@$msg_from_username meant to say: $last" \
			> /dev/null
	else
		status_put $msg_chat_id $msg_from_id 'last' "$msg_text"
	fi
}
