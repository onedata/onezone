#!/bin/bash

source /root/internal-scripts/common.sh

if [ $$ -ne 1 ]; then
	SCRIPT_NAME=$(basename "$0")
	echo "ERROR: the '$SCRIPT_NAME' script MUST be run as the main container process (PID 1)" \
	     "to ensure proper handling of termination signals."
	echo "However, the current PID is $$. If you are calling this script from a custom wrapper," \
	     "make sure to use the 'exec' command."
	exit 1
fi

function on_termination_signal {
    dispatch-log "Received a termination signal"
    /root/internal-scripts/onezone-ensure-stopped.sh
    dispatch-log "Main process exiting"
}

trap on_termination_signal SIGHUP SIGINT SIGTERM

# make sure the graceful stop marker is not set; see common.sh
rm -f ${GRACEFUL_STOP_LOCK_FILE}

# must be done before dispatch-log, which writes to a persistent directory
/root/persistence-dir.py --copy-missing-files

dispatch-log "Main process starting" extra_linebreak_in_log_file

if [ $1"x" == "bashx" ]; then
    /bin/bash  
elif [ $1"x" == "demox" ]; then
    echo Starting demo mode...
    echo Use https://$(hostname -i) to connect to onezone
    /root/demo.sh &
else
    echo Starting normal mode...
    /root/onezone.py &

fi
wait $!
