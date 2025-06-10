#!/bin/bash

# Set the directory for the root CA
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CERT_DIR="$SCRIPT_DIR/certs"

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

# Create the server's cert directory if it doesn't exist
mkdir -p "$CERT_DIR/$DOMAIN"

if [ -f $CERT_DIR/$DOMAIN/$DOMAIN.crt ]; then
   echo "Cerificate for $DOMAIN was already created."
   exit -1
fi

# Create the server's cert
openssl genrsa -out $CERT_DIR/$DOMAIN/$DOMAIN.key 2048 

# Create certificate signing request
openssl req -new -sha256 -key $CERT_DIR/$DOMAIN/$DOMAIN.key -config $SCRIPT_DIR/cert.conf -out $CERT_DIR/$DOMAIN/$DOMAIN.csr

# Verify the CSR's content
openssl req -in $CERT_DIR/$DOMAIN/$DOMAIN.csr -noout -text

# Generate the actual certificate
openssl x509 -req -in $CERT_DIR/$DOMAIN/$DOMAIN.csr -CA $SCRIPT_DIR/root_ca.crt -CAkey $SCRIPT_DIR/root_ca.key -CAcreateserial -out $CERT_DIR/$DOMAIN/$DOMAIN.crt -days 500 -sha256

# Verify the CRT's content
openssl x509 -in $CERT_DIR/$DOMAIN/$DOMAIN.crt -text -noout
