#!/bin/bash
# Aliases
alias echo="echo -e"

# Define global vars
JSON='./libs/JSON.sh/JSON.sh'
declare -A CMDS
declare -A HELPS
declare -a DEFS

command() {
	CMDS["$1"]="$2"
	HELPS["$1"]="$3"
}

default() {
	DEFS+=("$1")
}

# Include files
source help.sh
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

		# Set IFS to empty
		# Otherwise, it will unescape double quotes in the JSON
		while IFS= read -r update; do
			local u="$(echo "$update" | lval | $JSON)"
			local o=$(echo "$u" | val '"update_id"')

			if [[ -z $o ]]; then
				break
			fi

			# Increase the offset value
			if (( "$o" >= "$offset" )); then
				offset=$((${o#0} +1))
			else
				break
			fi

			# Check if it is a command
			local txt=$(echo "$u" | val '"message"' '"text"')
			txt="$(printf "$txt")" # printf does the UTF-8 processing
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

					local v="$(echo "$txt" | awk -vFPAT="([^ ]+)|('[^']+')" '{for (i=2; i<=NF; i++) print $i;}')"
					local arr=()
	
					while read line; do
						arr+=("$(echo "$line" | sed -e 's/^'"'"'\(.*\)'"'"'$/\1/')")
					done <<< "$v"

					echo "$u" | ${CMDS["$cmd"]} "${arr[@]}" &
					monitor_subshell $! &
				fi
			else
				# If there is a command that catches input
				# Distribute
				local chat_id=$(echo "$u" | val '"message"' '"chat"' '"id"')
				local from_id=$(echo "$u" | val '"message"' '"from"' '"id"')
				if [[ -f "$TMPDIR/$chat_id/$from_id/default" ]]; then
					echo "$u" | $(cat "$TMPDIR/$chat_id/$from_id/default") &
					monitor_subshell $! &
				else
					# We might also dispatch to default processors
					for d in "${DEFS[@]}"; do
						echo "$u" | $d &
						monitor_subshell $! &
					done
				fi
			fi
		done <<< "$updates"
	done
}

main
