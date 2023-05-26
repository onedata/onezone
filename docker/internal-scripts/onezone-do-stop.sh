#!/bin/bash
###-------------------------------------------------------------------
### Author: Lukasz Opiola
### Copyright (C): 2023 ACK CYFRONET AGH
### This software is released under the MIT license cited in 'LICENSE.txt'.
###-------------------------------------------------------------------
### This script attempts to stop all system services running in the
### Onezone docker container and reports if there are any errors.
###-------------------------------------------------------------------

source /root/internal-scripts/common.sh

function log_for_service {
    SERVICE_NAME=${1}
    LOG=${2}
    dispatch-log "[${SERVICE_NAME} service] ${LOG}"
}

function stop_service {
    log_for_service "${1}" "stopping..."
    RESULT=$(service "${1}" stop 2>&1)
    if [ ${?} -eq 0 ]; then
        log_for_service "${1}" "stopped gracefully"
    else
        log_for_service "${1}" "stop FAILED! Output was: \"${RESULT}\""
        return 1
    fi
}

ERR_COUNTER=0
stop_service oz_panel; ERR_COUNTER=$((ERR_COUNTER + $?))
stop_service oz_worker; ERR_COUNTER=$((ERR_COUNTER + $?))
stop_service cluster_manager; ERR_COUNTER=$((ERR_COUNTER + $?))
stop_service couchbase-server; ERR_COUNTER=$((ERR_COUNTER + $?))

if [ $ERR_COUNTER -eq 0 ]; then
    dispatch-log "All services have been stopped gracefully"
else
    dispatch-log "FAILURE! There have been errors when stopping the Onezone service (see above)."
    dispatch-log "This is not expected to happen and may indicate serious problems with the installation."
    exit 1
fi
