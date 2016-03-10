#!/bin/bash
# Telegram Bot API
API_BASE="https://api.telegram.org/bot$TOKEN/"

api_getMe() {
	curl -s "{$API_BASE}getMe" | $JSON
}

api_getUpdates() {
	curl -s -G "${API_BASE}getUpdates" \
		-d "offset=$1" -d "limit=$2" -d "timeout=$3" \
		| $JSON
}

api_sendMessage() {
	curl -s -X POST "${API_BASE}sendMessage" "$@" | $JSON
}
