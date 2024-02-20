#!/bin/sh

/prometheus/prometheus --config.file=/prometheus/prometheus.yml &

/grafana/bin/grafana-server -homepath /grafana &
#### grafana-server", "-dataDir=/data/grafana"]
/ping
