# internet-latency-gauge

Build the docker image: `docker build -t internet-latency-gauge .`
Run the docker image: `docker run --name internet-latency-gauge internet-latency-gauge`

# Run it
1. Compile the ping tool: `make build-go`
2. Build the container: `docker build -t internet-latency-gauge .`
3. Run the container: `docker run -p 9090:9090 -p 3000:3000 --hostname my-grafana-server --name internet-latency-gauge internet-latency-gauge`

# Use it
Access Grafana Dashboard at: http://localhost:3000/d/ca6fe3f1-d8a2-4e3d-aff0-2365902d1ddc
