# Use an Alpine Linux base image
FROM alpine:latest

# Set environment variables for Grafana
# Updated GF_VERSION to 12.1.0 (latest stable as of search)
# Updated GF_INFINITY_VERSION to 3.4.1 (latest stable as of search)
# Updated GF_PROMETHEUS_VERSION to 3.6.0 (latest stable as of search)
ENV GF_VERSION=12.1.0 \
    GF_INFINITY_VERSION=3.4.1 \
    GF_INSTALL_DIR="/usr/share/grafana" \
    GF_PATHS_CONFIG="/etc/grafana" \
    GF_PATHS_DATA="/var/lib/grafana" \
    GF_PATHS_HOME="/usr/share/grafana" \
    GF_PATHS_LOGS="/var/log/grafana" \
    GF_PATHS_DASHBOARDS="/var/lib/grafana/dashboards" \
    GF_PATHS_PLUGINS="/var/lib/grafana/plugins" \
    GF_PATHS_PROVISIONING="/etc/grafana/provisioning" \
    GF_ADMIN_USER="admin"

# Adding wrapper script for init CMD
ADD bin/commands_to_run.sh /tmp

# Install necessary packages:
# - ca-certificates: For HTTPS connections
# - wget: To download Grafana
# - unzip: To extract Grafana plugins
# - tar: To extract the Grafana archive
# - fontconfig, freetype: Required for Grafana's rendering capabilities
# - udev: Often a dependency for fontconfig/freetype in Alpine contexts
# - net-tools: Added for network troubleshooting within Container
# - prometheus: Necessary for the Prometheus data source
RUN apk add --no-cache \
    ca-certificates \
    wget \
    unzip \
    tar \
    fontconfig \
    freetype \
    udev \
    tzdata \
    net-tools \
    prometheus && \
    # Ensure appropriate permissions for init script
    chown grafana:grafana /tmp/commands_to_run.sh && \
    chmod 750 /tmp/commands_to_run.sh && \
    # Download Grafana
    # Updated URL to reflect the new GF_VERSION and filename pattern
    wget https://dl.grafana.com/oss/release/grafana-${GF_VERSION}.linux-amd64.tar.gz -O /tmp/grafana.tar.gz && \
    # Create Grafana directories
    mkdir -p ${GF_INSTALL_DIR} ${GF_PATHS_CONFIG} ${GF_PATHS_DATA} ${GF_PATHS_LOGS} ${GF_PATHS_DASHBOARDS} ${GF_PATHS_PLUGINS} ${GF_PATHS_PROVISIONING} && \
    # Extract Grafana to the installation directory
    tar -xzf /tmp/grafana.tar.gz --strip-components=1 -C ${GF_INSTALL_DIR} && \
    # Remove the downloaded archive
    rm /tmp/grafana.tar.gz && \
    # Download Grafana Infinity plugin
    wget https://storage.googleapis.com/integration-artifacts/yesoreyeram-infinity-datasource/release/${GF_INFINITY_VERSION}/linux/yesoreyeram-infinity-datasource-${GF_INFINITY_VERSION}.linux_amd64.zip -O /tmp/grafana-infinity.zip && \
    # Extract Plugin to plugins directory
    unzip /tmp/grafana-infinity.zip -d ${GF_PATHS_PLUGINS} && \
    # Remove the downloaded file
    rm /tmp/grafana-infinity.zip && \
    # Create a Grafana user and group
    addgroup -S grafana && adduser -S -G grafana grafana && \
    # Set appropriate permissions for Grafana directories
    chown -R grafana:grafana ${GF_PATHS_DATA} ${GF_PATHS_LOGS} ${GF_PATHS_PLUGINS} ${GF_PATHS_DASHBOARDS} ${GF_PATHS_PROVISIONING} && \
    chmod -R 750 ${GF_PATHS_DATA} ${GF_PATHS_LOGS} ${GF_PATHS_PLUGINS} ${GF_PATHS_DASHBOARDS} ${GF_PATHS_PROVISIONING} && \
    # Symlink grafana-cli to /bin (deprecated, but I prefer it so it stays.)
    ln -s ${GF_INSTALL_DIR}/bin/grafana-cli /bin/grafana-cli && \
    # Run Prometheus
    prometheus --config.file ${GF_PATHS_CONFIG}/prometheus.yml && \
    # Lastly, clean up apk cache
    rm -rf /var/cache/apk/* 

# Copy the configuration files from the host into the image
COPY grafana/config ${GF_PATHS_CONFIG}
# Copy the provisioning files into the image
COPY grafana/provisioning ${GF_PATHS_PROVISIONING}
# Copy the dashboard JSON files into the image
COPY grafana/dashboards ${GF_PATHS_DASHBOARDS}

# Expose Grafana's default port
EXPOSE 3000

# Expose Prometheus' default port
EXPOSE 9090

# Set the working directory
WORKDIR ${GF_INSTALL_DIR}

# Switch to the Grafana user
USER grafana

# Run commands_to_run.sh when the Container starts
CMD ["/tmp/commands_to_run.sh"]

# Then define the command to run Grafana when the container starts
#CMD ["./bin/grafana-server", \
#    "--homepath", "/usr/share/grafana", \
#    "--config", "/etc/grafana/grafana.ini", \
#    "cfg:default.paths.data=/var/lib/grafana", \
#    "cfg:default.paths.logs=/var/log/grafana", \
#    "cfg:default.paths.plugins=/var/lib/grafana/plugins", \
#    "cfg:default.paths.provisioning=/etc/grafana/provisioning"]
