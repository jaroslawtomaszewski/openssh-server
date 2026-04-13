#!/bin/sh

# ================================================
# Entry point for custom OpenSSH server container
# Compatible with Testcontainers + Kubedock + Podman
# ================================================

set -eu

# Default environment variables (same as linuxserver/openssh-server)
PUID="${PUID:-1000}"
PGID="${PGID:-1000}"
USER_NAME="${USER_NAME:-testuser}"
USER_PASSWORD="${USER_PASSWORD:-password}"
PASSWORD_ACCESS="${PASSWORD_ACCESS:-true}"

echo "=== SSH Container Configuration ==="
echo "User: ${USER_NAME} (UID=${PUID}, GID=${PGID})"

# Create group if it doesn't exist
if ! getent group "${USER_NAME}" >/dev/null 2>&1; then
    groupadd -g "${PGID}" "${USER_NAME}"
    echo "→ Group ${USER_NAME} created"
fi

# Create user if it doesn't exist
if ! getent passwd "${USER_NAME}" >/dev/null 2>&1; then
    useradd -u "${PUID}" -g "${PGID}" -m -s /bin/bash -d "/home/${USER_NAME}" "${USER_NAME}"
    echo "→ User ${USER_NAME} created"
fi

# Set user password (if password access is enabled)
if [ "${PASSWORD_ACCESS}" = "true" ] && [ -n "${USER_PASSWORD}" ]; then
    echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd
    echo "→ Password set for user ${USER_NAME}"
else
    echo "→ Password authentication disabled"
fi

# Generate host keys if they don't exist
if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
    ssh-keygen -A
    echo "→ SSH host keys generated"
fi

# Prepare runtime directory
mkdir -p /var/run/sshd
chmod 0755 /var/run/sshd

echo "=== Starting SSH daemon on port 2222 ==="

# Run sshd in foreground (required by Testcontainers)
exec /usr/sbin/sshd -D -e
