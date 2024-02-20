# Use Alpine Linux for its small size
FROM alpine:latest

# Set the environment variables
ENV LOCATION=HNL \
    PING_DEST="1.1.1.1,8.8.8.8"

# Copy the binary file from your host to the container
COPY ping /usr/local/bin/ping

# Make sure the ping binary is executable
RUN chmod +x /usr/local/bin/ping

# Command to run when the container starts (example: run your ping binary)
# This is just an example, replace it with the actual command you want to use
CMD ["/usr/local/bin/ping"]
