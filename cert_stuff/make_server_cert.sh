#!/bin/bash -x

server_name=$1
if [ "$server_name" = "" ]; then
    echo usage $0 server_fqdn
    exit 1
fi

cd root/ca
rm -rf intermediate/private/$server_name.key.pem
rm -rf intermediate/certs/$server_name.cert.pem
cd -

openssl genrsa  \
      -out root/ca/intermediate/private/$server_name.key.pem 2048
chmod 400 root/ca/intermediate/private/$server_name.key.pem

openssl req -batch -config int.openssl.cnf \
      -key root/ca/intermediate/private/$server_name.key.pem \
      -new -sha256 -out root/ca/intermediate/csr/$server_name.csr.pem

openssl ca -config int.openssl.cnf \
      -extensions server_cert -days 375 -notext -md sha256 \
      -in root/ca/intermediate/csr/$server_name.csr.pem \
      -out root/ca/intermediate/certs/$server_name.cert.pem

chmod 444 root/ca/intermediate/certs/$server_name.cert.pem


