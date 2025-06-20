#!/bin/bash

# Set the directory for the root CA
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CERT_DIR="$SCRIPT_DIR/certs/domains"
ROOT_DIR="$SCRIPT_DIR/certs/root"

# Read the domain name to set the server FQDN
read -p "Enter a domain name: " DOMAIN

if ! [ -d $CERT_DIR/$DOMAIN ]; then
    echo "No cerificates for $DOMAIN found."
    exit -1
fi

# Create certificate signing request
openssl req -new -sha256 -key $CERT_DIR/$DOMAIN/$DOMAIN.key -config $SCRIPT_DIR/cert.conf -out $CERT_DIR/$DOMAIN/$DOMAIN.csr

# Verify the CSR's content
#openssl req -in $CERT_DIR/$DOMAIN/$DOMAIN.csr -noout -text

# Re-generate the certificate in a temporary file
openssl x509 -req -in $CERT_DIR/$DOMAIN/$DOMAIN.csr -CA $ROOT_DIR/root_ca.crt -CAkey $ROOT_DIR/root_ca.key -CAcreateserial -out $CERT_DIR/$DOMAIN/$DOMAIN.crt.new -days 365 -sha256

# Replace old certificate and keep a backup
cat $CERT_DIR/$DOMAIN/$DOMAIN.crt > $CERT_DIR/$DOMAIN/$DOMAIN.crt.old
cat $CERT_DIR/$DOMAIN/$DOMAIN.crt.new > $CERT_DIR/$DOMAIN/$DOMAIN.crt
rm $CERT_DIR/$DOMAIN/$DOMAIN.crt.new
