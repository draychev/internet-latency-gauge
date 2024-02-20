# Use Alpine Linux for its small size
FROM alpine:latest

# Set the environment variables
ENV LOCATION=HNL \
    PING_DEST="1.1.1.1,8.8.8.8"

# Install necessary packages
RUN apk add --no-cache wget tar bash

# Download and Install Prometheus
ENV PROMETHEUS_VERSION 2.37.0
RUN wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz && \
    tar -xzf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz -C /tmp && \
    mv /tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64 /prometheus

# Download and Install Grafana
RUN wget https://dl.grafana.com/oss/release/grafana-9.1.7.linux-amd64.tar.gz && \
    tar -zxvf grafana-9.1.7.linux-amd64.tar.gz -C /tmp && \
    mv /tmp/grafana-9.1.7 /grafana

# Copy the binary file from your host to the container
COPY ping /usr/local/bin/ping

# Make sure the ping binary is executable
RUN chmod +x /usr/local/bin/ping

# Configure Prometheus to scrape metrics from localhost:9876
RUN echo "global:\n  scrape_interval: 15s\n  evaluation_interval: 15s\n\nscrape_configs:\n  - job_name: 'localhost'\n    static_configs:\n      - targets: ['localhost:9876']" > /prometheus/prometheus.yml

# Copy provisioning files and dashboard JSON
COPY dashboards.yml /grafana/conf/provisioning/dashboards/dashboards.yml
COPY dashboard.json /var/lib/grafana/dashboards/dashboard.json

# Create a startup script to run Prometheus, Grafana, and the ping binary
RUN echo -e "#!/bin/sh\n/prometheus/prometheus --config.file=/prometheus/prometheus.yml &\n/grafana/bin/grafana-server -homepath /grafana &\n/usr/local/bin/ping" > /start.sh && \
    chmod +x /start.sh

# Expose ports (3000 for Grafana, 9090 for Prometheus)
EXPOSE 3000 9090

# Command to run when the container starts
CMD ["/start.sh"]
