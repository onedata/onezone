#!/bin/bash
###-------------------------------------------------------------------
### Author: Lukasz Opiola
### Copyright (C): 2023 ACK CYFRONET AGH
### This software is released under the MIT license cited in 'LICENSE.txt'.
###-------------------------------------------------------------------
### Common constants and functions used in the Onezone container scripts.
###-------------------------------------------------------------------

# Presence of this file indicates that a graceful stop was already performed.
# It is deleted upon service start and created after the onezone-stop-graceful.sh succeeds.
GRACEFUL_STOP_LOCK_FILE='/root/graceful-stop.lock'
# A log file that includes a complete history of starts & stops or all onezone sub-services.
JOURNAL_LOG_FILE='/var/log/onezone/journal.log'

# Logs in a unified way to stdout and additionally to the journal log file.
# Optional literal argument "extra_linebreak_in_log_file" can be provided in ${2},
# which will add an extra linebreak in the log file only BEFORE the log (but only if
# the file is not empty).
function dispatch-log {
    echo "----------------------------------------------------------------------"
    echo "[$(date "+%F %H:%M:%S.%3N")] ${1}"
    echo "----------------------------------------------------------------------"

    if [ -s ${JOURNAL_LOG_FILE} ]; then
        if [[ "${2}" == "extra_linebreak_in_log_file" ]]; then
            echo "" >> ${JOURNAL_LOG_FILE}
        fi
    fi

    echo "[$(date "+%F %H:%M:%S.%3N")] ${1}" >> ${JOURNAL_LOG_FILE}
}
