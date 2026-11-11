#!/bin/bash

echo "Starting mitmproxy"

/usr/local/bin/mitmdump -s /app/main.py --set confdir=/data/mitmproxy-conf/ &
mitmdump_pid=$!

# Forward SIGTERM/SIGINT received from PID 1 (tini via `init: true`) to the
# background mitmdump; without the trap the signal may not reach it and shutdown can be delayed
trap 'kill -TERM "$mitmdump_pid" 2>/dev/null' TERM INT

wait "$mitmdump_pid"
exit_code=$?

# Only on abnormal exit (not 0 or 143 from SIGTERM), wait 30 seconds before exiting
# to avoid hammering the host with rapid restarts
if [ "$exit_code" -ne 0 ] && [ "$exit_code" -ne 143 ]; then
    echo "mitmdump exited with code $exit_code. Waiting 30s before exiting to avoid hammering the host with rapid restarts."
    sleep 30
fi

exit "$exit_code"