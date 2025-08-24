#!/bin/bash

# Command to run Grafana when the container starts as background process
bin/grafana-server \
--homepath "${GF_INSTALL_DIR}" \
--config "${GF_PATHS_CONFIG}" \
cfg:default.paths.data="${GF_PATHS_DATA}" \
cfg:default.paths.logs="${GF_PATHS_LOGS}" \
cfg:default.paths.plugins="${GF_PATHS_PLUGINS}" \
cfg:default.paths.provisioning="${GF_PATHS_PROVISIONING}" > /dev/null 2>&1 &

# Wait for the main process to be ready
sleep 5

# Command to run Prometheus when the container starts as background process
/usr/bin/prometheus \
--config.file "${GF_PATHS_CONFIG}/prometheus.yml" > /dev/null 2>&1  &

# Then, keep the container running with this process
tail -f /dev/null