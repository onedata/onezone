#!/bin/bash

source /root/demo-mode/demo-common.sh
source /root/demo-mode/better-curl.sh

ONEZONE_DOMAIN="onezone.internal"  # do not use .local as it messes with some DNS setups

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

sed "s/${HOSTNAME}\$/${HOSTNAME}-node.${ONEZONE_DOMAIN} ${HOSTNAME}-node/g" /etc/hosts > /tmp/hosts.new
cat /tmp/hosts.new > /etc/hosts
rm /tmp/hosts.new
echo "127.0.1.1 ${HOSTNAME}.${ONEZONE_DOMAIN} ${HOSTNAME}" >> /etc/hosts

# A simple heuristic to check if the DNS setup in the current docker runtime is
# acceptable; there is a known issue: if DNS lookups about the machine's FQDN
# take too long (or time out), couchbase will take ages to start.
START_TIME_NANOS=$(date +%s%N)
timeout 2 nslookup "$(hostname -f)" > /dev/null
LOOKUP_TIME_MILLIS=$((($(date +%s%N) - START_TIME_NANOS) / 1000000))
if [ "$LOOKUP_TIME_MILLIS" -gt 1000 ]; then
    echo "-------------------------------------------------------------------------"
    echo "The DNS config in your docker runtime may cause problems with the Couchbase DB startup"
    echo "since queries about the container's FQDN take too long."
    echo ""
    echo "Overriding the container's resolv.conf with 8.8.8.8 to avoid that."
    echo "-------------------------------------------------------------------------"
    echo ""
    echo "8.8.8.8" > /etc/resolv.conf
fi

cat << EOF > /etc/oz_worker/config.d/disable-gui-verification.config
[
    {oz_worker, [
        % verification is not relevant in demo deployments, and turning it off allows deploying
        % any Oneprovider version (especially not an official release) alongside Onezone
        {gui_package_verification, false}
    ]}
].
EOF

# Onezone batch installation config
export ONEPANEL_DEBUG_MODE="true" # prevents container exit on configuration error
export ONEPANEL_BATCH_MODE="true"
export ONEPANEL_LOG_LEVEL="info" # prints logs to stdout (possible values: none, debug, info, error), by default set to info
export ONEPANEL_EMERGENCY_PASSPHRASE="password"
export ONEPANEL_GENERATE_TEST_WEB_CERT="true"  # default: false
export ONEPANEL_GENERATED_CERT_DOMAIN="$IP"  # default: ""
export ONEPANEL_TRUST_TEST_CA="true"  # default: false

export ONEZONE_CONFIG=$(cat <<EOF
        cluster:
          domainName: "${ONEZONE_DOMAIN}"
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
            # set the lowest possible ram quota for couchbase for a lightweight deployment
            serverQuota: 256  # per-node Couchbase cache size in MB for all buckets
            bucketQuota: 256  # per-bucket Couchbase cache size in MB across the cluster
            nodes:
              - "n1"
        onezone:
          name: "Demo Onezone"
          domainName: "$IP"
          letsEncryptEnabled: false
EOF
)

# After the main process finishes here, the Onezone entrypoint is run.

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
