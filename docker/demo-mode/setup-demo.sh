#!/bin/bash

source /root/demo-mode/demo-common.sh

HOSTNAME=$(hostname)
IP=$(hostname -I | tr -d ' ')

echo -e "\e[1;33m"
echo "-------------------------------------------------------------------------"
echo "Starting Onezone in demo mode..."
echo "The IP address is: $IP"
echo "When the service is ready, an adequate log will appear here."
echo "You may also use the await script: \"docker exec \$CONTAINER_ID await\"."
echo "-------------------------------------------------------------------------"
echo -e "\e[0m"

export ONEPANEL_DEBUG_MODE="true" # prevents container exit on configuration error
export ONEPANEL_BATCH_MODE="true"
export ONEPANEL_LOG_LEVEL="info" # prints logs to stdout (possible values: none, debug, info, error), by default set to info
export ONEPANEL_EMERGENCY_PASSPHRASE="password"
export ONEPANEL_GENERATE_TEST_WEB_CERT="true"  # default: false
export ONEPANEL_GENERATED_CERT_DOMAIN="$IP"  # default: ""
export ONEPANEL_TRUST_TEST_CA="true"  # default: false

export ONEZONE_CONFIG=$(cat <<EOF
        cluster:
          domainName: "onezone.local"
          nodes:
            n1:
              hostname: "${HOSTNAME}"
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
          name: "Demo Onezone"
          domainName: "$IP"
          letsEncryptEnabled: false
EOF
)

sed "s/${HOSTNAME}\$/${HOSTNAME}-node.onezone.local ${HOSTNAME}-node/g" /etc/hosts > /tmp/hosts.new
cat /tmp/hosts.new > /etc/hosts
rm /tmp/hosts.new
echo "127.0.1.1 ${HOSTNAME}.onezone.local ${HOSTNAME}" >> /etc/hosts

cat << EOF > /etc/oz_worker/config.d/disable-gui-verification.config
[
    {oz_worker, [
        % verification is not relevant in demo deployments, and turning it off allows deploying
        % any Oneprovider version (especially not an official release) alongside Onezone
        {gui_package_verification, false}
    ]}
].
EOF

# Run an async process to await service readiness
{
    if ! await; then
        exit_and_kill_docker
    fi

    echo -e "\e[1;32m"
    echo "-------------------------------------------------------------------------"
    echo "Demo Onezone service is ready! Visit the GUI in your browser:"
    echo "  URL:      https://${IP}"
    echo "  username: admin"
    echo "  password: password"
    echo "  note:     you must add an exception for the untrusted certificate"
    echo "-------------------------------------------------------------------------"
    echo -e "\e[0m"
} &
