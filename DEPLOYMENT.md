# Pangolin Deployment Guide

This guide walks you through deploying and configuring Pangolin using the DigitalOcean Marketplace 1-Click App.

## Deployment Steps

### 1. Create a Droplet from the Marketplace

1. Log in to your [DigitalOcean account](https://cloud.digitalocean.com/).
2. Navigate to the Marketplace and search for "Pangolin".
3. Click on the Pangolin 1-Click App.
4. Configure your Droplet:
   - Choose a plan (recommended: at least 1GB RAM)
   - Select a datacenter region
   - Add SSH keys for authentication
   - Choose a hostname (e.g., pangolin-server)
5. Click "Create Droplet".

### 2. DNS Configuration

Before proceeding with setup, you need to configure your domain to point to your new Droplet:

1. Obtain your Droplet's IP address from the DigitalOcean control panel.
2. Go to your domain registrar or DNS provider.
3. Create an A record that points your domain or subdomain to your Droplet's IP address.
   ```
   Type: A
   Name: pangolin (or @ for root domain)
   Value: your_droplet_ip
   TTL: 3600 (or as low as possible for faster propagation)
   ```
4. Wait for DNS propagation (can take 5 minutes to several hours).

### 3. Initial Setup

1. Once your Droplet is created, connect to it via SSH:
   ```bash
   ssh root@your_droplet_ip
   ```

2. The first-login setup script will run automatically, guiding you through the initial configuration:
   - Enter your domain name
   - Provide your email for SSL certificates
   - The script will run the Pangolin installer

3. After the installer completes, you'll be able to access the Pangolin dashboard.

### 4. Dashboard Setup

1. Open a web browser and navigate to `https://your-domain.com`.
2. Follow the on-screen instructions to:
   - Create an admin account
   - Set up your organization
   - Configure your first site

### 5. Connecting Remote Sites

Pangolin allows you to connect remote sites using either the Newt client or standard WireGuard.

#### Using Newt (Recommended)

On your remote site (e.g., home server, private network):

1. Install Newt:
   ```bash
   curl -L https://github.com/fosrl/newt/releases/download/latest/install.sh | sudo bash
   ```

2. In the Pangolin dashboard:
   - Go to Sites > Add Site
   - Follow the instructions to generate a configuration
   - Copy the provided configuration

3. On your remote site, create a configuration file:
   ```bash
   sudo nano /etc/newt/config.yaml
   ```
   Paste the configuration from the dashboard.

4. Start Newt:
   ```bash
   sudo newt start
   ```

#### Using WireGuard

1. In the Pangolin dashboard:
   - Go to Sites > Add Site
   - Select WireGuard configuration
   - Download the configuration file

2. On your remote site, install WireGuard:
   ```bash
   # For Ubuntu/Debian
   sudo apt install wireguard
   
   # For CentOS/RHEL
   sudo yum install wireguard-tools
   ```

3. Copy the configuration file to `/etc/wireguard/wg0.conf`.

4. Start the WireGuard interface:
   ```bash
   sudo wg-quick up wg0
   ```

### 6. Exposing Resources

1. In the Pangolin dashboard, go to Resources > Add Resource.

2. Configure your resource:
   - Name: A descriptive name
   - Type: HTTP/HTTPS, TCP, or UDP
   - Target: The IP and port of the service on your private site
   - Domain: The domain or subdomain to access the resource
   - Access Control: Set authentication and permission rules

3. Save the resource configuration.

4. Your private resource is now securely accessible through Pangolin.

### 7. Security Considerations

- The Pangolin Droplet comes with UFW firewall pre-configured to allow only necessary ports.
- Set up 2FA for your admin account in the Pangolin dashboard.
- Consider setting up CrowdSec for additional protection against brute force attacks.
- Regularly update your Pangolin installation with the latest security patches.

### 8. Maintenance and Updates

To update Pangolin in the future:

1. SSH into your Droplet:
   ```bash
   ssh root@your_droplet_ip
   ```

2. Update the installer:
   ```bash
   cd /opt/pangolin
   wget -O installer "https://github.com/fosrl/pangolin/releases/download/latest/installer_linux_$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')"
   chmod +x ./installer
   ```

3. Run the installer:
   ```bash
   ./installer -y
   ```

## Troubleshooting

### Cannot Access Dashboard

1. Verify DNS configuration with `dig your-domain.com`.
2. Check that your domain points to your Droplet's IP address.
3. Ensure SSL certificates were issued correctly:
   ```bash
   cd /opt/pangolin
   docker compose logs traefik
   ```

### Connection Issues from Remote Sites

1. Verify the WireGuard/Newt tunnel is active:
   ```bash
   # For WireGuard
   sudo wg show
   
   # For Newt
   sudo newt status
   ```

2. Check firewall settings on both the Pangolin server and remote site.

3. Verify network connectivity with `ping` or `traceroute`.

## Need Help?

- Documentation: [https://docs.fossorial.io](https://docs.fossorial.io)
- Discord Community: [https://discord.gg/HCJR8Xhme4](https://discord.gg/HCJR8Xhme4)
- GitHub Issues: [https://github.com/fosrl/pangolin/issues](https://github.com/fosrl/pangolin/issues)
- Email Support: [numbat@fossorial.io](mailto:numbat@fossorial.io)