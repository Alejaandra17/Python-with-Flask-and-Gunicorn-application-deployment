#!/bin/bash

# CONFIGURATION VARIABLES
IP_SERVER="192.168.2.1"
SUBNET_OCTET="2"           # Third octet for the reverse zone
LAST_OCTET="1"             # Last octet of the server for PTR record
DOMAIN="test.dns"        # Practice domain

ZONE_FILE="/var/lib/bind/db.${DOMAIN}"
REV_ZONE_FILE="/var/lib/bind/db.${SUBNET_OCTET}.rev"

echo "3. DNS Server Installation"

# Update and install BIND9, utilities, and documentation
apt-get update
apt-get install -y bind9 bind9utils bind9-doc

echo "4. Server Configuration (IPv4)"

# Ensure BIND runs only with IPv4
echo 'OPTIONS="-u bind -4"' > /etc/default/named

echo "4.1-4.4. Copying and applying zone configurations"

# Copy BIND configuration files
cp /vagrant/config/named.conf.options /etc/bind/named.conf.options
cp /vagrant/config/named.conf.local /etc/bind/named.conf.local

# Copy zone files to /var/lib/bind and set permissions
cp /vagrant/config/db.${DOMAIN} $ZONE_FILE
cp /vagrant/config/db.${SUBNET_OCTET}.rev $REV_ZONE_FILE
chown bind:bind $ZONE_FILE
chown bind:bind $REV_ZONE_FILE

echo "4.5. Checking zone files"

# Check syntax of configuration files
named-checkconf /etc/bind/named.conf.options
named-checkconf /etc/bind/named.conf.local

# Check zone files
named-checkzone $DOMAIN $ZONE_FILE
named-checkzone "${SUBNET_OCTET}.168.192.in-addr.arpa" $REV_ZONE_FILE

echo "4.6. Restarting BIND9"

# Restart BIND to apply changes
systemctl restart bind9
systemctl status bind9

echo "5. Testing DNS"

# Test forward resolution
dig @127.0.0.1 debian.${DOMAIN}

# Test reverse resolution
dig @127.0.0.1 -x 192.168.${SUBNET_OCTET}.${LAST_OCTET}

echo "6. Java, Tomcat & Maven Installation"

# Install Maven (required for deployment)
apt-get install -y maven

apt-get install -y tomcat9 tomcat9-admin