FROM mcr.microsoft.com/devcontainers/python:3.10-bullseye

# --- Start: Proxy Certificate Setup ---
# Copy the corporate CA certificate into the image
COPY ./certificates /usr/local/share/ca-certificates/

# Update the CA certificates to include the new ones
# This command is for Debian/Ubuntu-based images
RUN chmod 644 /usr/local/share/ca-certificates/ && update-ca-certificates
# --- End: Proxy Certificate Setup ---






