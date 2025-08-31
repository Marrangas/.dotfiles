#!/usr/bin/env bash

current_jobs=0

xargs -0 -P 4 -n 1 bash -c

for task in "${tasks[@]}"; do
    echo "Processing $task..."
    (
        # Subshell to ensure variable changes don't affect parent or other loops
        # Simulate work
        echo "Starting work on $task..."
        sleep $((RANDOM % 5 + 1)) # Simulate variable work time
        echo "Finished work on $task."
    ) &

    ((current_jobs++))

    # If we hit the limit, wait for any job to finish before launching a new one
    if (( current_jobs >= MAX_CONCURRENT_JOBS )); then
        echo "Hit max concurrent jobs ($MAX_CONCURRENT_JOBS). Waiting for a slot to open..."
        wait -n # Wait for ANY single background job to complete (Bash 4.3+)
        # For older Bash versions, you might need a more complex loop with `jobs -p` and `wait <pid>`
        ((current_jobs--)) # Decrement as one job finished
    fi
done

coproc BC { bc -l; }

# Important: Always clean up file descriptors, especially in traps.
# Close the read/write FDs to the coprocess when the script exits.
# This prevents leaving open FDs and ensures the coprocess can exit cleanly.
trap "exec ${BC[0]}<&-; exec ${BC[1]}>&-; wait ${BC_PID} 2>/dev/null" EXIT

echo "Sending expressions to bc..."

echo "10 + 5" >&"${BC[1]}"
echo "sqrt(144)" >&"${BC[1]}"

# Close the write end of the pipe. This sends EOF to bc's stdin.
# 'bc' will process remaining input and then exit.
exec "${BC[1]}">&-

# Read results until EOF on BC[0]
read -r result1 <&"${BC[0]}" || { echo "Error reading result 1"; exit 1; }
echo "Result 1: $result1"

read -r result2 <&"${BC[0]}" || { echo "Error reading result 2"; exit 1; }
echo "Result 2: $result2"

# No need to send "quit" if we closed the pipe.
# The trap will handle waiting for BC_PID.
echo "Coprocess commands sent. Reading results..."

