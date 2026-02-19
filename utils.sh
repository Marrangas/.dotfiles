#!/usr/bin/env bash
#
# General utility functions for bash scripts.
#
# This library provides functions for checking dependencies, generating random
# strings, cleaning up files, and building regular expressions.
#
# Dependencies:
# - Sourcing script should source 'helper.sh' for logging.
# - Sourcing script may define a global '_requirements' array for 'utils_requirements'.
# - 'jq' is required for JSON manipulation functions.

set -euo pipefail
_lib_requirements=(fzf jq gcloud)

bold=$(tput bold)
normal=$(tput sgr0)

utils_trap_exit(){
    echo -e "\n${B}[ ] Script interrupted by user. Exiting.${nor}" >&2
    tput cnorm > /dev/null 2>&1
    exit 130
}

utils_requirements(){
	local all_reqs=("$@" "${_requirements[@]:-}" "${_lib_requirements[@]}")
	if [[ ${#all_reqs[@]} -eq 0 ]]; then
		return 0
	fi

	for cmd in "${all_reqs[@]}"; do
		if ! command -v "$cmd" &> /dev/null; then
			log "ERROR" "Required command '$cmd' not found in PATH. Please install it."
			exit 1
		fi
	done
}

utils_random_str(){
	local chars="${1:-8}" # Default to 8 characters
	local chars_pool="abcdefghijklmnopqrstuvwxyz0123456789"

	if ! [[ "$chars" =~ ^[0-9]+$ ]]; then
		log "ERROR" "utils_random_str: Argument must be a non-negative integer."
		return 1
	fi

	local random=""
	for ((i = 0; i < chars; i++)); do
		random+="${chars_pool:RANDOM%${#chars_pool}:1}"
	done
	echo "$random"
}

_utils_get_cpu_cores() {
	if command -v nproc &>/dev/null; then
		nproc --all
	elif command -v sysctl &>/dev/null; then
		sysctl -n hw.ncpu
	else
		echo 1 # Fallback to 1
	fi
}

utils_json_check() {
	log "INFO" "Checking for and removing invalid JSON files..."
	local cores
	cores=$(_utils_get_cpu_cores)

	find . -type f -name "*.json" -print0 | \
	xargs -0 -P "$cores" -I {} sh -c '
		file="{}"
		if ! jq -e . "$file" >/dev/null 2>&1; then
		rm -f "$file"
		echo "Removed invalid or empty JSON file: $file" >&2
		fi
	'

	log "INFO" "JSON check complete."
}

utils_json_clean() {
	log "INFO" "Cleaning empty files..."
	find . -type f -empty -delete

	log "INFO" "Cleaning JSON files with empty arrays..."
	local cores
	cores=$(_utils_get_cpu_cores)

	find . -type f -name "*.json" -print0 | \
	xargs -0 -P "$cores" -I {} sh -c '
		file="{}"
		# Check if file content, after removing whitespace, is exactly "[]"
		if [[ "$(jq -c . "$file" 2>/dev/null)" == "[]" ]]; then
			rm -f "$file"
			echo "Removed JSON file with empty array: $file" >&2
		fi
	'

	log "INFO" "Cleaning complete."
}

utils_pubsub_pull(){
	local start_time
	local timeout=120 # 2 minutes
	local pull_limit=100 # Pull up to 100 messages at a time
	start_time=$(date +%s)

	log "INFO" "Waiting for response for request ID: $_request_id"
	while true; do
		local messages_json
		messages_json=$(gcloud pubsub subscriptions pull "$RESPONSE_SUBSCRIPTION_ID" \
			--project="$GCP_PROJECT" \
			--format="json" \
			--limit="$pull_limit" \
			--no-auto-ack
		)

		if [[ -z "$messages_json" || "$messages_json" == "[]" ]]; then
			echo -n "."
			sleep 2
		else
			local found_message_data=""
			local ack_id_to_ack=""

			# Use jq to iterate over the JSON array of messages.
			# The 'read' command processes each line of output from jq.
			while IFS=$'\t' read -r ack_id encoded_data; do
				if [[ -z "$ack_id" || -z "$encoded_data" ]]; then
					continue
				fi

				local data
				data=$(echo "$encoded_data" | base64 --decode)
				local response_request_id
				response_request_id=$(echo "$data" | jq -r '.requestId')

				if [[ "$response_request_id" == "$_request_id" ]]; then
					log "INFO" "Found matching response for request ID: $_request_id"
					found_message_data="$data"
					ack_id_to_ack="$ack_id"
					break # Exit the inner while loop once we find our message
				else
					log "DEBUG" "Ignoring message in batch for request ${response_request_id} (looking for ${_request_id})"
				fi
			done < <(echo "$messages_json" | jq -r '.[] | "\(.ackId)\t\(.message.data)"')

			if [[ -n "$ack_id_to_ack" ]]; then
				echo -e "\n\n--- Response Received ---"
				echo "$found_message_data" | jq .
				echo "-------------------------"

				log "INFO" "Acknowledging message with ackId: ${ack_id_to_ack:0:15}..."
				gcloud pubsub subscriptions ack "$RESPONSE_SUBSCRIPTION_ID" \
					--project="$GCP_PROJECT" \
					--ack-ids="$ack_id_to_ack" > /dev/null
				break # We are done, break the main while loop
			fi
		fi

		local current_time
		current_time=$(date +%s)
		if (( current_time - start_time > timeout )); then
			log "ERROR" "Timeout waiting for response after $timeout seconds."
			exit 1
		fi
	done
}
