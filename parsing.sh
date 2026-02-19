#!/usr/bin/env bash

_ARGS_REMAINING=()
_DAEMON_MODE=false

parse_main_options() {
    local other_args=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) usage_all; example_all; exit 0 ;;
            --example) example_all; exit 0 ;;

            -d|--daemon) shift; _DAEMON_MODE=true
                log "DEBUG" "Global: Daemon mode set to $_DAEMON_MODE"
                ;;

            -v|--verbosity) shift
                if [[ -n "$1" ]]; then
                    case "$1" in
                        debug|DEBUG|info|INFO|warning|warn|WARNING|WARN|error|ERROR)
                            VERBOSITY=$(echo "$1" | tr '[:lower:]' '[:upper:]')
                            shift
                            ;;

                        *)
                            echo "ERROR: Global_options: Unknown verbosity level '$1'. Use 'debug', 'info', 'warn', or 'error'." >&2
                            exit 1
                            ;;
                    esac
                else
                    log "ERROR" "Global_options: verbosity requires an argument (e.g., 'debug | info | warn | error' )." || exit 1
                fi
                log "DEBUG" "Global: Verbosity set to: $VERBOSITY"
                ;;

            --log-name) shift; GCP_LOG_NAME="$1"; shift
                log "DEBUG" "Global: Log Name set to '$GCP_LOG_NAME'."
                ;;

            --log-project) shift; PROJECT_ID="$1"; shift
                log "DEBUG" "Global: Project ID set to '$PROJECT_ID'."
                ;;

            -p|--parallel|--jobs) shift; local job_val="$1"

                if [[ -n "$job_val" ]]; then
                    if [[ "$job_val" =~ ^[0-9]+$ ]] || [[ "$job_val" =~ ^[0-9]+%$ ]]; then
                        JOB_NUM="$job_val"
                    else
                        log "WARNING" "Global: Invalid value for parallelism ('$job_val'). Using default ($JOB_NUM)."
                    fi
                else
                    log "ERROR" "Global_options: --parallel requires an argument (e.g., '8' or '75%')." && exit 1
                fi
                shift
                ;;
            *)
                other_args+=("$1")
                shift
                ;;
        esac
    done

    set -- "${other_args[@]}"

    if $_DAEMON_MODE; then
        sudo mkdir -p /var/log/pano
        nohup "$0" "$@" > "/var/log/pano/$(date "+%F-%T").log" 2>&1 & disown
        log "NOTICE" "Global: $SCRIPT_NAME started in daemon mode. Check logs in /var/log/pano/"
        exit 0
    fi

    _ARGS_REMAINING=("$@")
    log "DEBUG" "Global: Arguments remaining '${_ARGS_REMAINING[*]}'."
}

usage_global_options() {
    echo
    echo -e "${B}${cy}GLOBAL OPTIONS:${nor}"
    echo -e "${cy}  -d, --daemon ${nor}           Run the script in daemon mode (background)."
    echo -e "                          Logs will be written to /var/log/$_CMD/."
    echo -e "${cy}  -p, --parallel <jobs> ${nor}  Set the number of parallel jobs for 'parallel' command."
    echo -e "                          Can be an integer (e.g., '8') or a percentage (e.g., '75%')."
    echo -e "                          Default is '${JOB_NUM}'."
    echo -e "${cy}  -v, --verbosity ${nor}        Increase verbosity. debug, info, warning, error."
    echo -e "${cy}  --log-project ${nor}          Override the log project to store the logs"
    echo -e "${cy}  --log-name ${nor}             Override the log name for this execution"
    echo -e ""
    echo -e "${cy}  -h, --help ${nor}             Display overall help message."
    echo -e "${cy}  --example ${nor}              Display overall examples."
    echo ""
}
