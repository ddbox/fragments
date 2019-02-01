#!/bin/bash -x
#source https://jamielinux.com/docs/openssl-certificate-authority/create-the-intermediate-pair.html
#assumes make_root_pair.sh has been run and you know the signing cert password
export STARTDIR=$(pwd)
mkdir -p root/ca/intermediate
cp int.openssl.cnf root/ca/intermediate
cd root/ca/intermediate
mkdir -p  certs crl csr newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber
#create intermediate key
cd ..
rm -rf intermediate/private/intermediate.key.pem
openssl genrsa -aes256 \
      -out intermediate/private/intermediate.key.pem 4096
chmod 400 intermediate/private/intermediate.key.pem
#create crl
openssl req -config intermediate/int.openssl.cnf -new -sha256 \
      -key intermediate/private/intermediate.key.pem \
      -out intermediate/csr/intermediate.csr.pem
#sign it with root cert
openssl ca -config root.openssl.cnf -extensions v3_intermediate_ca \
      -days 3650 -notext -md sha256 \
      -in intermediate/csr/intermediate.csr.pem \
      -out intermediate/certs/intermediate.cert.pem

chmod 444 intermediate/certs/intermediate.cert.pem
#check it
openssl x509 -noout -text \
      -in intermediate/certs/intermediate.cert.pem
openssl verify -CAfile certs/ca.cert.pem \
      intermediate/certs/intermediate.cert.pem





