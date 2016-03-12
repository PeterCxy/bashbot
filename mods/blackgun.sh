#!/bin/bash
default def_blackgun

def_blackgun() {
	parse_msg
	if [[ "$msg_text" != "${msg_text/\#RICH/}" ]]; then
		api_sendMessage \
			-d "chat_id=$msg_chat_id" \
			-d "text=穷。" \
			-d "reply_to_message_id=$msg_id" \
			> /dev/null
	fi
}
