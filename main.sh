#!/bin/bash
# Aliases
alias echo="echo -e"

# Define global vars
JSON='./libs/JSON.sh/JSON.sh'
declare -A CMDS
declare -A HELPS

command() {
	CMDS["$1"]="$2"
	HELPS["$1"]="$3"
}

# Include files
source CONFIG
source utility.sh
source api.sh

# Main function
main() {
	# Who am I?
	ME=$(api_getMe | val '"result"' '"username"')
	echo "I am $ME"

	# Get updates
	local offset=0
	while true; do
		local updates="$(api_getUpdates $offset 10 600 | jval '"result"' '[0-9]+')"
		while read update; do
			local u="$(echo $update | lval | $JSON)"
			local o=$(echo "$u" | val '"update_id"')

			# Increase the offset value
			if (( "$o" >= "$offset" )); then
				offset=$((${o#0} +1))
			else
				break
			fi

			# Check if it is a command
			local txt=$(echo "$u" | val '"message"' '"text"')
			if [[ "$txt" == "/"* ]]; then
				# A command!
				local cmd=$(echo "$txt" | awk '{print $1}' | sed 's/\///')
				
				# To avoid confilicting with other bots
				# If the command contains '@'
				# Then we only respond to commands that are to us
				if [[ "$cmd" == *"@"* ]]; then
					local name=$(echo $cmd | awk -F '@' '{print $2}')
					cmd=$(echo $cmd | awk -F '@' '{print $1}')
					[[ "$name" != "$ME" ]] && continue
					echo "To: $name"
				fi

				echo "Command: $cmd"

				# Distribute it to command functions
				if [[ ! -z ${CMDS["$cmd"]} ]]; then
					echo "Command $cmd found."

					echo "$u" | ${CMDS["$cmd"]} "$txt" &
					monitor_subshell $! &
				fi
			fi
		done <<< "$updates"
	done
}

main
