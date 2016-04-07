#!/bin/sh

if [ "$ONEPANEL_MULTICAST_ADDRESS" ]; then
	sed -i s/239.255.0.1/"$ONEPANEL_MULTICAST_ADDRESS"/g /etc/oz_panel/app.config;
fi

sed -i s/onepanel@127.0.0.1/onepanel@`hostname -f`/g /etc/oz_panel/vm.args;
service oz_panel start

if [ "$ONEPANEL_BATCH_MODE" ]; then
	oz_panel_admin --install "$ONEPANEL_BATCH_MODE_CONFIG"
fi

while true; do sleep 60; done
