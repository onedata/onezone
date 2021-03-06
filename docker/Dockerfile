ARG BASE_IMAGE
FROM ${BASE_IMAGE}
MAINTAINER Krzysztof Trzepla <krzysztof.trzepla@gmail.com>

# Build arguments
ARG RELEASE
ARG RELEASE_TYPE
ARG DISTRIBUTION=bionic
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

# Backup files from persistence, as the persistent volume will be overwritten
# by mounting it from host. The missing files will be copied back in entrypoint.
ADD persistence-dir.py /root/persistence-dir.py
RUN python /root/persistence-dir.py --backup-persistent-files

# Create symlinks to persistence
RUN python /root/persistence-dir.py --create-symlinks

# Add entrypoint scripts
ADD onezone.sh /root/onezone.sh
ADD onezone.py /root/onezone.py

# Disable http_proxy for normal operation
ENV http_proxy ""

EXPOSE 53 53/udp 80 443 9443

CMD ["/root/onezone.sh"]
