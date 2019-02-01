#!/bin/bash -x
#source: https://jamielinux.com/docs/openssl-certificate-authority/create-the-root-pair.html
#edit root.openssl.cnf to taste prior to running
#you will be prompted for a password which you must save for later
export STARTDIR=$(pwd)
mkdir -p  root/ca
cp root.openssl.cnf root/ca
cd root/ca
mkdir -p certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
rm -rf private/ca.key.pem
# create root key
openssl genrsa -aes256 -out private/ca.key.pem 4096
chmod 400 private/ca.key.pem
# create root certificate
STARTDIR=$STARTDIR openssl req -config root.openssl.cnf \
      -key private/ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out certs/ca.cert.pem
chmod 444 certs/ca.cert.pem
#verify
openssl x509 -noout -text -in certs/ca.cert.pem
