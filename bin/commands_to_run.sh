#!/bin/bash

# Run the grafana-server process
/bin/grafana-server --homepath /usr/share/grafana \
--config /etc/grafana/grafana.ini \
cfg:default.paths.data=/var/lib/grafana \
cfg:default.paths.logs=/var/log/grafana \
cfg:default.paths.plugins=/var/lib/grafana/plugins \
cfg:default.paths.provisioning=/etc/grafana/provisioning &

# Then start Prometheus
/usr/bin/prometheus \
--config.file /etc/grafana/prometheus.yml &