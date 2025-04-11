#!/bin/bash
set -e

# Configure firewall
echo "Configuring firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 51820/udp  # WireGuard
ufw --force enable

# Install and configure fail2ban
echo "Configuring fail2ban..."
apt-get install -y fail2ban
cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
EOF

systemctl enable fail2ban
systemctl restart fail2ban