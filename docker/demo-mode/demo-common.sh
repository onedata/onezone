#!/bin/bash
###-------------------------------------------------------------------
### Author: Lukasz Opiola
### Copyright (C): 2024 ACK CYFRONET AGH
### This software is released under the MIT license cited in 'LICENSE.txt'.
###-------------------------------------------------------------------
### Constants and functions used in the demo mode related scripts.
###-------------------------------------------------------------------

exit_and_kill_docker() {
    >&2 echo -e "\e[1;31m"
    >&2 echo "-------------------------------------------------------------------------"
    >&2 echo "ERROR: Unrecoverable failure, killing the docker in 10 seconds."
    >&2 echo "-------------------------------------------------------------------------"
    >&2 echo -e "\e[0m"

    sleep 10

    kill -9 "$(pgrep -f /root/onezone.py)"
    exit 1
}
