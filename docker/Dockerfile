ARG BASE_IMAGE
FROM ${BASE_IMAGE}
MAINTAINER Krzysztof Trzepla <krzysztof.trzepla@gmail.com>

# Build arguments
ARG RELEASE
ARG RELEASE_TYPE
ARG DISTRIBUTION=bionic
ARG OZ_PANEL_VERSION
ARG COUCHBASE_VERSION
ARG CLUSTER_MANAGER_VERSION
ARG OZ_WORKER_VERSION
ARG ONEZONE_VERSION
ARG ONEPANEL_AUTOSTART=false

# Add users and groups
RUN groupadd -g 150 onedata && \
    useradd -u 151 -g 150 -d /var/lib/oz_panel oz_panel && \
    useradd -u 152 -g 150 -d /var/lib/cluster_manager cluster_manager && \
    useradd -u 153 -g 150 -d /var/lib/oz_worker oz_worker

# Get the image up to date and install utility tools
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install ca-certificates curl locales net-tools \
                       python python-pip python-yaml \
                       iproute2 dnsutils iperf3 traceroute vim && \
    apt-get clean

RUN pip install requests

# Generate locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install onezone package
RUN case ${RELEASE_TYPE} in \
        production) \
            curl -O http://get.onedata.org/onezone-${RELEASE}.sh; \
            ;; \
        *) \
            curl -O http://onedata-dev-packages.cloud.plgrid.pl/onezone-${RELEASE}.sh; \
            ;; \
    esac && \
    sh onezone-${RELEASE}.sh oz-panel=${OZ_PANEL_VERSION}-1~${DISTRIBUTION} && \
    sh onezone-${RELEASE}.sh couchbase-server-community=${COUCHBASE_VERSION}-1 && \
    sh onezone-${RELEASE}.sh cluster-manager=${CLUSTER_MANAGER_VERSION}-1~${DISTRIBUTION} && \
    sh onezone-${RELEASE}.sh oz-worker=${OZ_WORKER_VERSION}-1~${DISTRIBUTION} && \
    sh onezone-${RELEASE}.sh onezone=${ONEZONE_VERSION}-1~${DISTRIBUTION} && \
    rm -f onezone-${RELEASE}.sh

# Backup files from persistence, as the persistent volume will be overwritten
# by mounting it from host. The missing files will be copied back in entrypoint.
ADD persistence-dir.py /root/persistence-dir.py
RUN python /root/persistence-dir.py --backup-persistent-files

# Create symlinks to persistence
RUN python /root/persistence-dir.py --create-symlinks

EXPOSE 53 53/udp 80 443 9443

# Add entrypoint scripts
ADD onezone.sh /root/onezone.sh
ADD onezone.py /root/onezone.py

CMD ["/root/onezone.sh"]
