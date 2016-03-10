#!/bin/bash
command "hello" cmd_hello "Just hello"

cmd_hello() {
	api_sendMessage \
		-d "chat_id=$(echo "$1" | val '"message"' '"chat"' '"id"')" \
		-d "text=Hello, @$(echo "$1" | val '"message"' '"from"' '"username"')" \
		> /dev/null
}
