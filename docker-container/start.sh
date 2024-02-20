#!/bin/sh

/prometheus/prometheus --config.file=/prometheus/prometheus.yml &

/usr/share/grafana/bin/grafana-server --config=/etc/grafana/grafana.ini --homepath=/usr/share/grafana &
#### grafana-server", "-dataDir=/data/grafana"]

/ping
