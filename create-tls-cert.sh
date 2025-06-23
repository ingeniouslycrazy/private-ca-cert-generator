#!/bin/bash

# Set the directory for creating everything
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR

# Read the domain name to set the server FQDN
read -p "Enter a domain name: " DOMAIN

# Validate domain name
validate="^([a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\.)+[a-zA-Z]{2,}$"

# If user doesn't enter anything
if [[ -z "$DOMAIN" ]]; then
    echo "You must enter a domain"
fi

if [[ "$DOMAIN" =~ $validate ]]; then
    echo "Valid $DOMAIN name."
else
    echo "Not valid $DOMAIN name."
    exit -1
fi

# Create TLS CSR
EXPORT SAN="DNS:www.simple.org"
openssl req -new -nodes \
    -config "./config/root-ca.conf" \
    -out "./certs/$DOMAIN.csr" \
    -keyout "./certs/$DOMAIN.key"

# Create TLS CRT
openssl ca \
    -config "./config/signing-ca.conf" \
    -in "./certs/$DOMAIN.csr" \
    -out "./certs/$DOMAIN.crt" \
    -extensions server_ext \
    -batch

# Clean up
rm ./certs/$DOMAIN.csr
