#!/bin/bash
# Install Certbot and request a certificate for your domain

DOMAIN="your.domain.com"  # <-- Change this to your actual domain

sudo apt-get update
sudo apt-get install -y certbot

# For Nginx (recommended for reverse proxy)
sudo apt-get install -y python3-certbot-nginx

# Request certificate (replace with your domain)
sudo certbot certonly --nginx -d $DOMAIN

echo "Certificate obtained. Your certs are in /etc/letsencrypt/live/$DOMAIN/"
