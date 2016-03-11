#!/bin/bash
command "hello" cmd_hello "Just hello"

cmd_hello() {
	parse_msg
	api_sendMessage \
		-d "chat_id=$msg_chat_id" \
		-d "text=Hello, @$msg_from_username" \
		> /dev/null
}
