#!/bin/bash

source /root/internal-scripts/common.sh

function on_termination_signal {
    dispatch-log "Received a termination signal"
    /root/internal-scripts/onezone-ensure-stopped.sh
    dispatch-log "Main process exiting"
}

trap on_termination_signal SIGHUP SIGINT SIGTERM

# make sure the graceful stop marker is not set; see common.sh
rm -f ${GRACEFUL_STOP_LOCK_FILE}

dispatch-log "Main process starting" extra_linebreak_in_log_file

/root/onezone.py &
wait $!
