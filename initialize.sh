#!/bin/bash

# https://pki-tutorial.readthedocs.io/en/latest/simple/index.html

# Set the directory for creating everything
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd $SCRIPT_DIR

# 0 Create directories
mkdir -p "./ca/root-ca/private" "./ca/root-ca/db" "./ca/signing-ca/private" "./ca/signing-ca/db" "./crl" "./certs"
chmod 700 "./ca/root-ca/private"
chmod 700 "./ca/signing-ca/private"

if [ -f $SCRIPT_DIR/ca/root-ca.crt ]; then
    echo "Root CA was already created, skipping."
else

  # Create Root CA
  # 1 Create database
  touch "./ca/root-ca/db/root-ca.db"
  echo 01 > "./ca/root-ca/db/root-ca.crt.srl"
  echo 01 > "./ca/root-ca/db/root-ca.crl.srl"

  # 2 Create request
  openssl req -new -nodes \
      -config "./config/root-ca.conf" \
      -out "./ca/root-ca.csr" \
      -keyout "./ca/root-ca/private/root-ca.key"

  # 3 Create certificate
  openssl ca -selfsign \
      -config "./config/root-ca.conf" \
      -in "./ca/root-ca.csr" \
      -out "./ca/root-ca.crt" \
      -extensions root_ca_ext \
      -batch

  # 4 Clean up and final words
  rm $SCRIPT_DIR/ca/root-ca.csr

fi

if [ -f $SCRIPT_DIR/ca/signing-ca.crt ]; then
    echo "Signing CA was already created, skipping."
else

  #Create Signing CA
  # 1 Create database
  touch "./ca/signing-ca/db/signing-ca.db"
  echo 01 > "./ca/signing-ca/db/signing-ca.crt.srl"
  echo 01 > "./ca/signing-ca/db/signing-ca.crl.srl"

  # 2 Create request
  openssl req -new -nodes \
      -config "./config/signing-ca.conf" \
      -out "./ca/signing-ca.csr" \
      -keyout "./ca/signing-ca/private/signing-ca.key"

  # 3 Create and sign certificate
  openssl ca \
      -config "./config/root-ca.conf" \
      -in "./ca/signing-ca.csr" \
      -out "./ca/signing-ca.crt" \
      -extensions signing_ca_ext \
      -batch

  # 4 Clean up and final words
  rm $SCRIPT_DIR/ca/signing-ca.csr

fi

if [ -f $SCRIPT_DIR/crl/signing-ca.crl ]; then
    echo "Certificate Revokation List was already created, skipping."
else
  openssl ca -gencrl -config "./config/signing-ca.conf" \
      -out "./crl/signing-ca.crl"
fi

echo "Root CA certificate: $SCRIPT_DIR/ca/root-ca.crt"
echo "Signing CA certificate: $SCRIPT_DIR/ca/signing-ca.crt"
echo "Certificate Revokation List: $SCRIPT_DIR/crl/signing-ca.crl"
