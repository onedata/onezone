#!/bin/bash

export ONEPANEL_DEBUG_MODE="true" # prevents container exit on configuration error
export ONEPANEL_BATCH_MODE="true"
export ONEPANEL_LOG_LEVEL="info" # prints logs to stdout (possible values: none, debug, info, error), by default set to info
export ONEPANEL_EMERGENCY_PASSPHRASE="password"
export ONEPANEL_GENERATE_TEST_WEB_CERT="false"  # default: false
export ONEPANEL_GENERATED_CERT_DOMAIN=""  # default: ""
export ONEPANEL_TRUST_TEST_CA="false"  # default: false

export ONEZONE_CONFIG=$(cat <<EOF
        cluster:
          domainName: "onezone.local"
          nodes:
            n1:
              hostname: "demo"
          managers:
            mainNode: "n1"
            nodes:
              - "n1"
          workers:
            nodes:
              - "n1"
          databases:
            nodes:
              - "n1"
        onezone:
          name: "demo"
          domainName: "onezone.local"
          letsEncryptEnabled: true
EOF
)
if grep -q 'demo$' /etc/hosts; then
    sed 's/demo/demo-node.onezone.local demo-node/g' /etc/hosts > /tmp/hosts.new
    cat /tmp/hosts.new > /etc/hosts
    rm /tmp/hosts.new
    echo "127.0.1.1 demo.onezone.local demo" >> /etc/hosts
    /root/onezone.py
else
    echo The hostname is not demo. Please run the docker with "-h demo" option.
    exit 1
fi
    
