#!/usr/bin/env bash
# Common helper functions for bash scripts.
#
# This library provides common functions for logging, user confirmation,
# and error handling.
#
# Dependencies:
# - gcloud: for logging to Google Cloud Logging.
# - jq: for safely constructing JSON payloads.
# - The sourcing script should define 'bold' and 'normal' TPUT variables.

usage_helper() {
	local func_name=$1
	usage_"${func_name:-all}"
}

example_helper() {
	local func_name=$1
	example_"${func_name:-all}"
}

helper_help() {
	local name=$1
	shift
	case $1 in
		--example)
			# 'example_helper' is expected to be defined in the sourcing script.
			# It should display an example for the given component.
			example_helper "${name}" || exit 1
			exit 0
			;;

		--help)
			# 'usage_helper' is expected to be defined in the sourcing script.
			# It should display usage for the given component.
			usage_helper "${name}" || exit 1
			exit 0
			;;
	esac
}

helper_error() {
    local component_name="$1"
    local invalid_value="$2"
    # fatal error handler. It prints a message and then exits the script.
    # It depends on `usage_helper` and `usage_help`
    # being defined in the calling script to display context-specific help.
    echo -e "\nInvalid ${component_name}: ${bold}${invalid_value}${normal}" >&2
    echo "${bold}Please provide one of the following options:${normal}" >&2

    usage_helper "${component_name}" || exit 1
    exit 1
}


helper_confirm() {
    local prompt_message="$1"
    local response

    local input_source="/dev/tty"
    # If running in a non-interactive session (like CI/tests) or if stdin is piped, read from stdin.
    if [[ -n "${BATS_TEST_RUNNER:-}" || ! -t 0 ]]; then
        input_source="/dev/stdin"
    fi

    if [[ -z "$prompt_message" ]]; then
        log "ERROR" "Developer error: prompt_message for helper_confirm cannot be empty."
        return 2
    fi

    while true; do
        read -r -p "${prompt_message} [y/N]: " response < "$input_source"
	# Default to No if user just presses Enter
        response=${response:-n}
        case "$response" in
            [yY][eE][sS]|[yY]) return 0 ;;
            [nN][oO]|[nN]) return 1 ;;
            *) echo "Invalid input. Please enter 'yes' or 'no'." >&2 ;;
        esac
    done
}

