#!/bin/bash

# Set the directory for the root CA
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR="${SCRIPT_DIR}/certs/root"

if [ -f $ROOT_DIR/root_ca.crt ]; then
   echo "Root CA was already created."
   exit -1
else
  mkdir -p "${ROOT_DIR}"
fi

# 1. Generate the root CA private key
openssl genrsa -out "$ROOT_DIR/root_ca.key" 2048

# 2. Generate the Root CA certificate (self-signed)
openssl req -x509 -new -nodes -key "$ROOT_DIR/root_ca.key" -out "$ROOT_DIR/root_ca.crt" -days 3650 -subj "/CN=My-Certificate-Authority"

# Customize the Root CA certificate, this part is optional but good for clarity
# Modify the certificate with extended attributes
# openssl x509 -in "$ROOT_DIR/root_ca.crt" -out "$ROOT_DIR/root_ca_extended.crt" -extfile <(cat <<EOF
# [v3_ca]
# basicConstraints=critical,CA:TRUE
# keyUsage=keyCertSign, cRLSign
# subjectAltName=DNS:my.domain.com
# EOF
# ) -passin pass:my_password

# Optional: Remove the initial Root CA certificate if you replace it with an extended version.
# rm "$ROOT_DIR/root_ca.crt"

# 3. Save the Root CA key and certificate
echo "Root CA key: $ROOT_DIR/root_ca.key"
