#!/bin/sh

/prometheus/prometheus --config.file=/prometheus/prometheus.yaml &

/usr/share/grafana/bin/grafana-server --config=/etc/grafana/grafana.ini --homepath=/usr/share/grafana &

/ping
