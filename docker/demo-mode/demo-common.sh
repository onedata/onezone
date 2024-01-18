#!/bin/bash
###-------------------------------------------------------------------
### Author: Lukasz Opiola
### Copyright (C): 2024 ACK CYFRONET AGH
### This software is released under the MIT license cited in 'LICENSE.txt'.
###-------------------------------------------------------------------
### Constants and functions used in the demo mode related scripts.
###-------------------------------------------------------------------


exit_and_kill_docker() {
    kill -9 "$(pgrep -f /root/onezone.py)"
    exit 1
}


do_curl() {
    echo "" > /tmp/curl-resp-body.txt
    if ! curl -vks --output /tmp/curl-resp-body.txt --write-out '%{http_code}' "$@" &> /tmp/curl-output.txt; then
        return 1
    fi
    # the code is written out to the last line of the output
    HTTP_CODE=$(tail -n 1 /tmp/curl-output.txt)
    cat /tmp/curl-resp-body.txt
    if [ "$HTTP_CODE" -ge 400 ]; then
        return 1
    else
        return 0
    fi
}


success_curl() {
    if ! do_curl "$@"; then
        echo "[ERROR] cURL command failed!"
        echo "---------------------------------------"
        echo "Args: $*"
        echo "---------------------------------------"
        echo "Output: $(cat /tmp/curl-output.txt)"
        echo "---------------------------------------"
        echo "Response body: $(cat /tmp/curl-resp-body.txt)"
        echo "---------------------------------------"
        echo "Exiting due to the above error."
        exit_and_kill_docker
    fi
}
