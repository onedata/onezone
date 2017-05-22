#!/bin/bash

function stop_service {
  echo -e "Stopping ${2:-$1}..."
  service $1 stop >/dev/null 2>&1
}

function stop_onezone {
  echo -e "\nGracefully stopping onezone...\n"

  stop_service oz_panel
  stop_service oz_worker
  stop_service cluster_manager
  stop_service couchbase-server couchbase

  echo -e "\nAll services stopped. Exiting..."

  exit 0
}

trap stop_onezone SIGHUP SIGINT SIGTERM

/root/onezone.py &
wait $!
