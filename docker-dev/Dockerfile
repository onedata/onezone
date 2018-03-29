FROM onedata/worker:v57
MAINTAINER Krzysztof Trzepla <krzysztof.trzepla@gmail.com>

# Build arguments
ARG COUCHBASE_VERSION
ARG CLUSTER_MANAGER_VERSION
ARG OZ_PANEL_VERSION
ARG OZ_WORKER_VERSION
ARG ONEZONE_VERSION
ARG ONEPANEL_AUTOSTART=false

# Get the image up to date
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get clean

# Install onezone package
RUN curl -O http://onedata-dev-packages.cloud.plgrid.pl/onezone.sh && \
    sh onezone.sh couchbase-server-community=${COUCHBASE_VERSION}-1 && \
    sh onezone.sh cluster-manager=${CLUSTER_MANAGER_VERSION}-1 && \
    sh onezone.sh oz-panel=${OZ_PANEL_VERSION}-1 && \
    sh onezone.sh oz-worker=${OZ_WORKER_VERSION}-1 && \
    sh onezone.sh onezone=${ONEZONE_VERSION}-1 && \
    rm -f onezone.sh

EXPOSE 53 53/udp 80 443 9443
