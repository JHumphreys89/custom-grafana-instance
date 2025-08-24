#!/bin/bash

# Command to run Grafana when the container starts
bin/grafana-server \
--homepath "${GF_INSTALL_DIR}" \
--config "${GF_PATHS_CONFIG}" \
cfg:default.paths.data="${GF_PATHS_DATA}" \
cfg:default.paths.logs="${GF_PATHS_LOGS}" \
cfg:default.paths.plugins="${GF_PATHS_PLUGINS}" \
cfg:default.paths.provisioning="${GF_PATHS_PROVISIONING}"

# Command to run Prometheus when the container starts
/usr/bin/prometheus \
--config.file "${GF_PATHS_CONFIG}/prometheus.yml"