#!/bin/bash
###-------------------------------------------------------------------
### Author: Lukasz Opiola
### Copyright (C): 2024 ACK CYFRONET AGH
### This software is released under the MIT license cited in 'LICENSE.txt'.
###-------------------------------------------------------------------
### A wrapper for the cURL command for easier handling of errors and different
### results. Each cURL call gets its own directory in the tmp dir for helper files
### and logs (that help in debug if something goes sideways).
###-------------------------------------------------------------------

source /root/demo-mode/demo-common.sh

###===================================================================
### private helpers
###===================================================================

COMMON_TMP_DIR=/tmp/curl-calls

__make_temp_dir() {
    TEMP_DIR_NAME="$(date '+%H:%M:%S')-$(uuidgen | cut -d "-" -f5)"
    TMP_DIR_PATH="${COMMON_TMP_DIR}/${TEMP_DIR_NAME}"
    mkdir -p "${TMP_DIR_PATH}"
    echo "${TMP_DIR_PATH}"
}

__output_file() {
    TMP_DIR=$1
    echo "${TMP_DIR}/cmd-output.txt"
}

__response_body_file() {
    TMP_DIR=$1
    echo "${TMP_DIR}/resp-body.txt"
}

__debug_log_file() {
    TMP_DIR=$1
    echo "${TMP_DIR}/debug-log.txt"
}


__do_curl_internal() {
    CMD_OUTPUT_FILE=${1}
    RESP_BODY_FILE=${2}
    DEBUG_LOG_FILE=${3}
    shift 3

    printf "%b\n" "[$(date)]\ncurl $*" >> "${DEBUG_LOG_FILE}"

    if ! curl -vks --output "${RESP_BODY_FILE}" --write-out '%{http_code}' "$@" &> "${CMD_OUTPUT_FILE}"; then
        # general failure; the command failed to make any request to the server
        printf "\nERROR: call FAILED due to exitcode != 0\n" >> "${DEBUG_LOG_FILE}"
        return 1
    fi

    # print the response body to stdout
    cat "${RESP_BODY_FILE}"

    # the code is written out to the last line of the output
    HTTP_CODE=$(tail -n 1 "${CMD_OUTPUT_FILE}")

    if [ "$HTTP_CODE" -ge 400 ]; then
        printf "\nERROR: call FAILED due to HTTP code >= 400\n" >> "${DEBUG_LOG_FILE}"
        return 1
    else
        printf "\nOK: call successful\n" >> "${DEBUG_LOG_FILE}"
        return 0
    fi
}


###===================================================================
### public API
###===================================================================


do_curl() {
    TEMP_DIR=$(__make_temp_dir)
    CMD_OUTPUT_FILE=$(__output_file "${TEMP_DIR}")
    RESP_BODY_FILE=$(__response_body_file "${TEMP_DIR}")
    DEBUG_LOG_FILE=$(__debug_log_file "${TEMP_DIR}")
    __do_curl_internal "${CMD_OUTPUT_FILE}" "${RESP_BODY_FILE}" "${DEBUG_LOG_FILE}" "$@"
}


success_curl() {
    TEMP_DIR=$(__make_temp_dir)
    CMD_OUTPUT_FILE=$(__output_file "${TEMP_DIR}")
    RESP_BODY_FILE=$(__response_body_file "${TEMP_DIR}")
    DEBUG_LOG_FILE=$(__debug_log_file "${TEMP_DIR}")
    if ! __do_curl_internal "${CMD_OUTPUT_FILE}" "${RESP_BODY_FILE}" "${DEBUG_LOG_FILE}" "$@"; then
        >&2 echo "ERROR: cURL command failed!"
        >&2 echo "---------------------------------------"
        >&2 echo "Command output: $(cat ${CMD_OUTPUT_FILE})"
        >&2 echo "---------------------------------------"
        >&2 echo "Response body: $(cat ${RESP_BODY_FILE})"
        >&2 echo "---------------------------------------"
        >&2 echo "Debug log: $(cat ${DEBUG_LOG_FILE})"
        exit_and_kill_docker
    fi
}
