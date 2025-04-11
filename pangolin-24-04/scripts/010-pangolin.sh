#!/bin/bash
set -e

# Create directories for Pangolin
mkdir -p /opt/pangolin

# Download the Pangolin installer
echo "Downloading Pangolin installer..."
wget -O /opt/pangolin/installer "https://github.com/fosrl/pangolin/releases/download/${application_version}/installer_linux_$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')"
chmod +x /opt/pangolin/installer

# Create first-login setup script
cat > /opt/pangolin/setup.sh << 'EOF'
#!/bin/bash

# Colors for better UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

clear
echo -e "${BLUE}=================================================================${NC}"
echo -e "${GREEN}Welcome to Pangolin - Tunneled Mesh Reverse Proxy${NC}"
echo -e "${BLUE}=================================================================${NC}"
echo ""
echo -e "This script will help you set up Pangolin on your DigitalOcean Droplet."
echo ""
echo -e "${YELLOW}Important:${NC} Before continuing, make sure you have:"
echo "  1. A domain name pointing to this server's IP address"
echo "  2. Your email address for LetsEncrypt SSL certificates"
echo ""
read -p "Press Enter to continue..."

# Run the installer
echo ""
echo -e "${BLUE}Running Pangolin Installer...${NC}"
echo ""
cd /opt/pangolin
./installer -y

# Get the configured domain from config.yml
DOMAIN=$(grep -A1 "dashboard_url" /opt/pangolin/config/config.yml | grep "https://" | awk -F"https://" '{print $2}')

# Post-installation info
echo ""
echo -e "${GREEN}Pangolin has been installed successfully!${NC}"
echo ""
echo -e "${YELLOW}Important Next Steps:${NC}"
echo "1. Access Pangolin at: https://${DOMAIN}"
echo "2. Complete the initial setup wizard in your browser"
echo "   Note: It might take a few minutes for Traefik to generate SSL certificates"
echo "3. See the documentation at: https://docs.fossorial.io"
echo ""
echo -e "${YELLOW}Configuration Information:${NC}"
echo "- Configuration directory: /opt/pangolin/config"
echo "- Main configuration file: /opt/pangolin/config/config.yml"
echo ""
echo -e "${YELLOW}Security Information:${NC}"
echo "To keep this Droplet secure, the UFW firewall is enabled."
echo "All ports are BLOCKED except 22 (SSH), 80 (HTTP), 443 (HTTPS), and 51820 (WireGuard)."
echo -e "${RED}Recommendation:${NC} For improved security, consider restricting SSH access (port 22)"
echo "to only your IP address using: ${GREEN}ufw allow from YOUR_IP to any port 22${NC} or set up a DigitalOcean Cloud Firewall: https://docs.digitalocean.com/products/networking/firewalls/"
echo ""
echo -e "${BLUE}Thank you for using Pangolin from the DigitalOcean Marketplace.${NC}"
echo ""

# Remove this script from .bashrc
sed -i '/setup.sh/d' /root/.bashrc

EOF

chmod +x /opt/pangolin/setup.sh

# Add to root's .bashrc to run on first login
echo "/opt/pangolin/setup.sh" >> /root/.bashrc

# Create per-instance startup script
mkdir -p /var/lib/cloud/scripts/per-instance
cat > /var/lib/cloud/scripts/per-instance/01-setup-pangolin.sh << 'EOF'
#!/bin/bash

# This script runs on first boot of a newly created Droplet
# to prepare the system for Pangolin setup

# Set the hostname to 'pangolin'
hostnamectl set-hostname pangolin

# Ensure Docker is running
systemctl enable docker
systemctl start docker

EOF

chmod +x /var/lib/cloud/scripts/per-instance/01-setup-pangolin.sh

# Create a README file in /opt/pangolin
cat > /opt/pangolin/README.md << 'EOF'
# Pangolin - Tunneled Mesh Reverse Proxy

Welcome to your Pangolin server! This guide will help you get started.

## What is Pangolin?

Pangolin is a self-hosted tunneled mesh reverse proxy server with identity and access control, designed to securely expose private resources on distributed networks. It connects isolated networks through encrypted tunnels, enabling easy access to remote services without opening ports.

## Key Features

- Expose private resources without opening ports (firewall punching)
- Secure site-to-site connectivity via WireGuard tunnels
- Automated SSL certificates via LetsEncrypt
- Support for HTTP/HTTPS and raw TCP/UDP services
- Centralized authentication system
- Role-based access control

## Getting Started

1. When you first log in, the setup script will guide you through the initial configuration.
2. Make sure your domain is pointing to this server's IP address before running the setup.
3. After completing the setup, you can access the Pangolin dashboard at `https://your-domain.com`.

##  Licensing
Pangolin is dual licensed under the AGPL-3 and the Fossorial Commercial license. To see our commercial offerings, please see our website for details. For inquiries about commercial licensing, please contact us at numbat@fossorial.io.

## Documentation

For detailed documentation, visit: https://docs.fossorial.io

## Support

Need help? Join the community:
- Discord: https://discord.gg/HCJR8Xhme4
- Email: numbat@fossorial.io
- GitHub: https://github.com/fosrl/pangolin
EOF

echo "Pangolin installation files prepared."