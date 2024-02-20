FROM debian:bookworm
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
     && apt-get upgrade -y \
     && apt-get install \
     -y --no-install-recommends \
     apt-transport-https software-properties-common wget inetutils-ping wget tar curl

# Set the environment variables
ENV LOCATION=HNL \
    PING_DEST="1.1.1.1,8.8.8.8"

# Import the GPG key:
RUN mkdir -p /etc/apt/keyrings/
RUN wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | tee /etc/apt/keyrings/grafana.gpg > /dev/null

# Add a repository for stable releases
RUN echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | tee -a /etc/apt/sources.list.d/grafana.list

# Updates the list of available packages
RUN apt-get update

# Installs the latest OSS release:
RUN apt-get install -y grafana

# --- Prometheus

# Download and Install Prometheus
ENV PROMETHEUS_VERSION 2.37.0
RUN wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz && \
   tar -xzf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz -C /tmp && \
   mv /tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64 /prometheus

# ---

# Copy the binary file from your host to the container
COPY bin/ping /ping

# Make sure the ping binary is executable
RUN chmod +x /ping

COPY docker-container/prometheus.yml /prometheus/prometheus.yml

COPY dashboards.yml /grafana/conf/provisioning/dashboards/dashboards.yml
COPY dashboard.json /var/lib/grafana/dashboards/dashboard.json

COPY docker-container/start.sh /start.sh
RUN chmod +x /start.sh

# Expose ports (3000 for Grafana, 9090 for Prometheus)
EXPOSE 3000 9090

RUN ls -lah /

# Command to run when the container starts
CMD ["/start.sh"]
