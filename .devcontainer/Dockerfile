FROM mcr.microsoft.com/devcontainers/python:dev-3.12-bullseye

# Switch to vscode user
USER vscode

# Set pip proxy and trusted-host for the vscode user
RUN pip config set global.proxy gateway.pt.zscaler.net:80 \
 && pip config set global.trusted-host pypi.python.org \
 && pip config set global.trusted-host pypi.org \
 && pip config set global.trusted-host files.pythonhosted.org

# Switch back to root if needed for later steps
USER root

# --- Start: Proxy Certificate Setup ---
# Copy the corporate CA certificate into the image
COPY ./certificates /usr/local/share/ca-certificates/

# Update the CA certificates to include the new ones
# This command is for Debian/Ubuntu-based images
RUN chmod 644 /usr/local/share/ca-certificates/ && update-ca-certificates
# --- End: Proxy Certificate Setup ---






