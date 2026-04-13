# OpenSSH Server image optimized for Podman, Kubedock, Dev Spaces and OpenShift
FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

# Install OpenSSH server and utilities for user management
RUN microdnf install -y openssh-server shadow-utils && \
    microdnf clean all && \
    rm -rf /var/cache/microdnf

# SSH configuration using drop-in file (best practice on RHEL/UBI)
RUN mkdir -p /etc/ssh/sshd_config.d /var/run/sshd && \
    echo 'Port 2222' > /etc/ssh/sshd_config.d/99-testcontainers.conf && \
    echo 'PermitRootLogin no' >> /etc/ssh/sshd_config.d/99-testcontainers.conf && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config.d/99-testcontainers.conf && \
    echo 'PermitEmptyPasswords no' >> /etc/ssh/sshd_config.d/99-testcontainers.conf && \
    echo 'UsePAM no' >> /etc/ssh/sshd_config.d/99-testcontainers.conf

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose SSH port
EXPOSE 2222

# SSH daemon must run as root (standard for OpenSSH containers)
USER 0

ENTRYPOINT ["/entrypoint.sh"]
