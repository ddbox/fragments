#!/bin/bash -x

server_name=$1
if [ "$server_name" = "" ]; then
    echo usage $0 server_fqdn
    exit 1
fi

cd root/ca
rm -rf intermediate/private/$server_name.key.pem
rm -rf intermediate/certs/$server_name.cert.pem

openssl genrsa  \
      -out intermediate/private/$server_name.key.pem 2048
chmod 400 intermediate/private/$server_name.key.pem

openssl req -config intermediate/int.openssl.cnf \
      -key intermediate/private/$server_name.key.pem \
      -new -sha256 -out intermediate/csr/$server_name.csr.pem

openssl ca -config intermediate/int.openssl.cnf \
      -extensions server_cert -days 375 -notext -md sha256 \
      -in intermediate/csr/$server_name.csr.pem \
      -out intermediate/certs/$server_name.cert.pem

chmod 444 intermediate/certs/$server_name.cert.pem


