ARG BASE_IMAGE
FROM ${BASE_IMAGE}
MAINTAINER Krzysztof Trzepla <krzysztof.trzepla@gmail.com>

# Build arguments
ARG RELEASE
ARG RELEASE_TYPE
ARG DISTRIBUTION=focal
ARG OZ_PANEL_VERSION
ARG CLUSTER_MANAGER_VERSION
ARG OZ_WORKER_VERSION
ARG ONEZONE_VERSION
ARG ONEPANEL_AUTOSTART=false
ARG HTTP_PROXY

# Install onezone package
RUN case ${RELEASE_TYPE} in \
        production) \
            curl -O http://packages.onedata.org/onezone-${RELEASE}.sh; \
            ;; \
        *) \
            curl -O http://packages.devel.onedata.org/onezone-${RELEASE}.sh; \
            ;; \
    esac && \
    sh onezone-${RELEASE}.sh oz-panel=${OZ_PANEL_VERSION}-1~${DISTRIBUTION} && \
    sh onezone-${RELEASE}.sh cluster-manager=${CLUSTER_MANAGER_VERSION}-1~${DISTRIBUTION} && \
    sh onezone-${RELEASE}.sh oz-worker=${OZ_WORKER_VERSION}-1~${DISTRIBUTION} && \
    sh onezone-${RELEASE}.sh onezone=${ONEZONE_VERSION}-1~${DISTRIBUTION} && \
    rm -f onezone-${RELEASE}.sh

RUN pip3 install pyYAML
RUN apt install -y python-is-python2

# Backup files from persistence, as the persistent volume will be overwritten
# by mounting it from host. The missing files will be copied back in entrypoint.
ADD persistence-dir.py /root/persistence-dir.py
RUN python3 /root/persistence-dir.py --backup-persistent-files
# Create symlinks to persistence
RUN python3 /root/persistence-dir.py --create-symlinks

# Add scripts handling service starting and stopping
ADD onezone.sh /root/onezone.sh
ADD demo /usr/local/bin/demo
ADD await /usr/local/bin/await
ADD setup-demo.sh /root/setup-demo.sh
ADD onezone.py /root/onezone.py
ADD onezone-stop-graceful.sh /root/onezone-stop-graceful.sh
ADD internal-scripts/onezone-do-stop.sh /root/internal-scripts/onezone-do-stop.sh
ADD internal-scripts/onezone-ensure-stopped.sh /root/internal-scripts/onezone-ensure-stopped.sh
ADD internal-scripts/common.sh /root/internal-scripts/common.sh

# Disable http_proxy for normal operation
ENV http_proxy ""

EXPOSE 53 53/udp 80 443 9443

CMD ["/root/onezone.sh"]
