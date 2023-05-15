#!/bin/bash
###-------------------------------------------------------------------
### Author: Lukasz Opiola
### Copyright (C): 2023 ACK CYFRONET AGH
### This software is released under the MIT license cited in 'LICENSE.txt'.
###-------------------------------------------------------------------
### This script must be called before Onezone docker container termination
### to ensure a graceful stop, and should be allowed a possibly long time
### to run, especially if the service is busy.
###
### After the script has finished, it is safe to shut down the Onezone
### docker container. The script then leaves a
###
### The output is also printed to the main process's stdout.
###-------------------------------------------------------------------

source /root/internal-scripts/common.sh


{

dispatch-log "Graceful stop initiated..."

cat <<EOF

----------------------------------------------------------------------
Gracefully stopping the Onezone service...
Allow some time for all in-memory application state to be persisted.
The shutdown may take longer (even several minutes) if the service is busy.

WARNING: interrupting the process or forcing a shutdown may cause
database inconsistencies or loss of recent changes in persistent data!
----------------------------------------------------------------------

EOF

/root/internal-scripts/onezone-do-stop.sh

if [ ${?} -eq 0 ]; then
    touch ${GRACEFUL_STOP_LOCK_FILE}  # save indication that graceful stop was already done; see common.sh
    dispatch-log "The container can now be safely stopped."
fi

} | tee /proc/1/fd/1
