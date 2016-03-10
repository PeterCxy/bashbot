#!/bin/bash
command "hello" cmd_hello "Just hello"

cmd_hello() {
	local u=$(cat)
	api_sendMessage \
		-d "chat_id=$(echo "$u" | val '"message"' '"chat"' '"id"')" \
		-d "text=Hello, @$(echo "$u" | val '"message"' '"from"' '"username"')" \
		> /dev/null
}
