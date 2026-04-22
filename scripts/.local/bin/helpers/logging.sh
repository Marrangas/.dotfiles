#!/usr/bin/env bash

log() {
    local severity="$1"
    local message="$2"

    # --- Verbosity Mapping & Check ---
    # A message is logged to stderr only if its level is >= the global $VERBOSITY level.
    declare -A -r severity_levels=(
        ["DEBUG"]=0 ["INFO"]=1 ["NOTICE"]=2 ["WARNING"]=3
        ["ERROR"]=4 ["CRITICAL"]=5 ["ALERT"]=6 ["EMERGENCY"]=7
    )
    local severity_upper
    severity_upper=$(echo "$severity" | tr '[:lower:]' '[:upper:]')
    local message_level=${severity_levels[$severity_upper]:-1}      # Default to INFO if severity is unknown
    local verbosity_level=${severity_levels[${VERBOSITY:-INFO}]:-1} # Default to INFO if verbosity is unset

    # --- Remote Logging (to Google Cloud) ---
    # This part always runs to ensure all logs are captured remotely,
    # regardless of local verbosity settings.
    # The check for local display happens after this.
    local log_project="${GCP_LOG_PROJECT:-dia-oficina-cloud}"
    local log_name="${GCP_LOG_NAME:-oficina-cloud-custom}"    # The name of the log stream.
    local log_user="${USER:-$(gcloud config get-value account 2>/dev/null || echo "unknown_user")}"
    local log_sa="${GCP_LOG_SA:-not_impersonated}" # SA being impersonated, if any.
    local log_version="${GCP_LOG_VERSION:-v1.0}" # Version of the calling script.
    local log_interactive="${SET_INTERACTIVE:-true}"

    local payload
    payload=$(jq -n \
        --arg msg "$message" \
        --arg user "$log_user" \
        --arg sa "$log_sa" \
        --arg version "$log_version" \
        --argjson interactive "${log_interactive:-true}" \
        '{message: $msg, user: $user, serviceAccount: $sa, version: $version, details: {interactive: $interactive}}')

    if [[ -z "$payload" ]]; then
        echo "ERROR: Failed to create JSON payload for logging. Is 'jq' installed and in PATH?" >&2
        return 1
    fi

    gcloud logging write "$log_name" "$payload" --severity="$severity" --payload-type=json --project="$log_project" --quiet --verbosity=none > /dev/null 2>&1

    # --- Console Logging (to stderr) ---
    # Only print to stderr if the message severity is high enough for the current verbosity.
    if (( message_level < verbosity_level )); then
        return 0
    fi

    local color="${w:-}"
    # https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry#LogSeverity
    case "${severity_upper}" in
        DEBUG) color="${cy:-}";;
        INFO) color="${g:-}";;
        NOTICE) color="${b:-}";;
        WARNING) color="${y:-}";;
        ERROR|CRITICAL|EMERGENCY) color="${r:-}";;
        ALERT) color="${mg:-}";;
    esac

    echo -e "${b:-}${color}${severity_upper}:${nor:-} ${message}" >&2
}
