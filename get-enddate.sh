#!/bin/bash

# Set the directory for the root CA
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CERT_DIR="$SCRIPT_DIR/certs"

# Read the domain name to set the server FQDN
read -p "Enter a domain name: " DOMAIN

if ! [ -d $SCRIPT_DIR/certs/$DOMAIN ]; then
    echo "No cerificates for $DOMAIN found."
    exit -1
fi

openssl x509 -enddate -noout -in $SCRIPT_DIR/certs/$DOMAIN/$DOMAIN.crt 