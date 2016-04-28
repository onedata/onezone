#!/bin/bash

set -e

ROOT="/data"
DIRS=("/etc/oz_panel" "/etc/oz_worker" "/etc/cluster_manager" "/var/lib/oz_panel" \
    "/usr/lib64/oz_panel" "/opt/couchbase/var/lib/couchbase" "/var/log/oz_panel" \
    "/var/log/oz_worker" "/var/log/cluster_manager")

function is_configured {
    if [ -n "`oz_panel_admin --config | grep undefined`" ]; then
        return 1
    else
        return 0
    fi
}

function add_dirs {
    for DIR in "${DIRS[@]}"; do
        if [ ! -e "$ROOT/$DIR" ]; then
            PARENT_DIR="$ROOT/`dirname $DIR`"
            mkdir -p "$PARENT_DIR"
            mv "$DIR" "$PARENT_DIR"
        fi
        rm -rf "$DIR"
        ln -sf "$ROOT/$DIR" "$DIR"
    done
}

function remove_dirs {
    for DIR in "${DIRS[@]}"; do
        rm -rf "$ROOT/$DIR"
    done
}

function start_services {
    service couchbase-server start 2> /dev/null
    service cluster_manager start 2> /dev/null
    service oz_worker start 2> /dev/null
}

add_dirs

if [ "$ONEPANEL_MULTICAST_ADDRESS" ]; then
    sed -i -e s/"{multicast_address, .*}"/"{multicast_address, \"$ONEPANEL_MULTICAST_ADDRESS\"}"/g /etc/oz_panel/app.config
fi

sed -i -e s/"-name .*"/"-name onepanel@`hostname -f`"/g /etc/oz_panel/vm.args

service oz_panel start 2> /dev/null

if is_configured; then
    start_services
elif [ "$ONEPANEL_BATCH_MODE" == "true" ]; then
    oz_panel_admin --install "$ONEPANEL_BATCH_MODE_CONFIG" || \
    (remove_dirs && exit 1)
fi

while true; do sleep 60; done
