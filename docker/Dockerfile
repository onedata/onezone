FROM ubuntu:16.04
MAINTAINER Krzysztof Trzepla <krzysztof.trzepla@gmail.com>

# Build arguments
ARG RELEASE
ARG OZ_PANEL_VERSION
ARG CLUSTER_MANAGER_VERSION
ARG OZ_WORKER_VERSION
ARG ONEZONE_VERSION
ARG ONEPANEL_AUTOSTART=false

# Add users and groups
RUN groupadd -g 110 onedata && \
    useradd -u 107 -g 110 -d /var/lib/oz_panel oz_panel && \
    useradd -u 108 -g 110 -d /var/lib/cluster_manager cluster_manager && \
    useradd -u 109 -g 110 -d /var/lib/oz_worker oz_worker

# Get the image up to date and install utility tools
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install ca-certificates curl locales net-tools \
                       python python-setuptools python-yaml traceroute vim && \
    easy_install requests && \
    apt-get clean

# Generate locale
RUN locale-gen en_US.UTF-8

# Install onezone package
RUN case ${RELEASE} in \
        production) \
            curl -O http://get.onedata.org/onezone.sh; \
            ;; \
        *) \
            curl -O http://onedata-dev-packages.cloud.plgrid.pl/onezone.sh; \
            ;; \
    esac && \
    sh onezone.sh oz-panel=${OZ_PANEL_VERSION}-1 && \
    sh onezone.sh cluster-manager=${CLUSTER_MANAGER_VERSION}-1 && \
    sh onezone.sh oz-worker=${OZ_WORKER_VERSION}-1 && \
    sh onezone.sh onezone=${ONEZONE_VERSION}-1 && \
    rm -f onezone.sh

EXPOSE 53 53/udp 80 443 5555 5556 6665 6666 7443 8443 8876 8877 9443

# Add entrypoint scripts
ADD onezone.sh /root/onezone.sh
ADD onezone.py /root/onezone.py

RUN mkdir -p /volumes/persistence
VOLUME ["/volumes/persistence"]

CMD ["/root/onezone.sh"]
