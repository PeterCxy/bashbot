#!/bin/bash
command "hello" cmd_hello "Just hello"
command "echo" cmd_echo "Echo the arguments passed to this command."

cmd_hello() {
	parse_msg
	api_sendMessage \
		-d "chat_id=$msg_chat_id" \
		-d "text=Hello, @$msg_from_username" \
		> /dev/null
}

cmd_echo() {
	parse_msg
	api_sendMessage \
		-d "chat_id=$msg_chat_id" \
		-d "text=$@" \
		> /dev/null
}
