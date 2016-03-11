#!/bin/bash
command 'remind' cmd_remind 'A simple interactive reminder'

cmd_remind() {
	parse_msg
	api_sendMessage \
		-d "chat_id=$msg_chat_id" \
		-d "text=(・∀・) What to remind you of?" \
		-d "reply_to_message_id=$msg_id" \
		> /dev/null
	status_catch $msg_chat_id $msg_from_id def_remind
	status_put $msg_chat_id $msg_from_id 'step' 0
}

def_remind() {
	parse_msg
	local step=$(status_get $msg_chat_id $msg_from_id 'step')
	case $step in
	0)
		status_put $msg_chat_id $msg_from_id 'text' $msg_text
		api_sendMessage \
			-d "chat_id=$msg_chat_id" \
			-d "text=(>ω<) Okay. How much time later should I remind you?" \
			-d "reply_to_message_id=$msg_id" \
			> /dev/null
		status_put $msg_chat_id $msg_from_id 'step' 1
		;;
	1)
		api_sendMessage \
			-d "chat_id=$msg_chat_id" \
			-d "text=(^_-) Yes, sir!" \
			-d "reply_to_message_id=$msg_id" \
			> /dev/null

		local text="$(status_get $msg_chat_id $msg_from_id 'text')"
		status_release $msg_chat_id $msg_from_id
		sleep $msg_text && {
			api_sendMessage \
				-d "chat_id=$msg_chat_id" \
				-d "text=@$msg_from_username $text" \
				> /dev/null
		} &
		;;
	esac
}
