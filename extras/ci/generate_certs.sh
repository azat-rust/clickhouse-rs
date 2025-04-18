#!/usr/bin/env bash

ca_crt=${1:-"$CH_SSL_CA_CERTIFICATE"} && shift
crt=${1-:"$CH_SSL_CERTIFICATE"} && shift
key=${1-:"$CH_SSL_PRIVATE_KEY"} && shift

ca_key=${ca_crt/.pem/.key}
csr=${key/.key/.csr}
ext=${key/.key/.ext}

openssl genrsa -out "$ca_key" 4096
openssl req -x509 -new -nodes -key "$ca_key" -sha256 -days 3650 -out "$ca_crt" -subj "/C=US/ST=DevState/O=DevOrg/CN=MyDevCA"

openssl genrsa -out "$key" 2048
openssl req -new -key "$key" -out "$csr" -subj "/C=US/ST=DevState/O=DevOrg/CN=localhost"

cat > "$ext" <<EOL
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
EOL

openssl x509 -req -in "$csr" -CA "$ca_crt" -CAkey "$ca_key" -CAcreateserial -out "$crt" -days 825 -sha256 -extfile "$ext"
openssl verify -CAfile "$ca_crt" "$crt"
