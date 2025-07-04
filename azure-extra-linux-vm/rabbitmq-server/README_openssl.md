# Certificate store CA


## CA

The openssl.cnf for used here was translated to Linux.

```bash

cd rmq-x2-ssl
mkdir cert-store
cd cert-store
mkdir certs
ls
openssl.cnf

openssl version
OpenSSL 3.0.2 15 Mar 2022 (Library: OpenSSL 3.0.2 15 Mar 2022)

mkdir certs private
chmod 700 private # remove all permission
echo 01 > serial # should have content 01
touch > index.txt
ls
certs  index.txt  openssl.cnf  private  serial

# Next we need to generate the key and certificates that our test Certificate Authority will use. Since we are uing a custom openssl.cnf we have already added where the key should be stored.
# You could generate your own key with a password protection
# https://www.ibm.com/docs/en/license-metric-tool?topic=certificate-step-1-creating-private-keys-certificates

# 1 Generate the key and cert
/rmq-x2-ssl/cert-store

openssl req -x509 -config openssl.cnf -newkey rsa:2048 -days 3652 -out ca_certificate.pem -outform PEM -subj /CN=SocratesIncCa/ -nodes


/rmq-x2-ssl/cert-store/private ls
ca_private_key.pem

/rmq-x2-ssl/cert-store ls
ca_certificate.pem  certs  index.txt  openssl.cnf  private  serial

# Generate certificate DER form
openssl x509 -in ca_certificate.pem  -out ca_certificate.cer -outform DER

/rmq-x2-ssl/cert-store ls
ca_certificate.cer  ca_certificate.pem  certs  index.txt  openssl.cnf  private  serial

# view the CN
openssl x509 -noout -subject -in ca_certificate.pem

subject=CN = SocratesIncCa

# view extensions, KeyUsage must be Certificate Signing, Off-line CRL Signing, CRL Signing (06) or at least keyCertSign, cRLSign
openssl x509 -noout -ext keyUsage < ca_certificate.pem
# X509v3 Key Usage:
#    Certificate Sign, CRL Sign

# This is all that is needed to generate a test Certificate Authority. The root certificate is in ca_certificate.pem and is also in ca_certificate.cer. 
# These two files contain the same information, but in different formats, PEM and DER. 
# Most software uses the former but some tools require the latter.
```

## Certificates for server (client) rmq_client.cloud

rmq_client.cloud

```bash
cd cert-store
mkdir client

# Generating RSA private key
openssl genrsa -out ./client/private_key.pem 2048

# Generating request
openssl req -new -key ./client/private_key.pem -out ./client/req.pem -outform PEM -subj /CN=rmq_client.cloud -nodes

# Server and client extension
openssl ca -config openssl.cnf -in ./client/req.pem -out ./client/client_certificate.pem -notext -batch -extensions client_server_extension

# Using configuration from openssl.cnf
# Check that the request matches the signature
# Signature ok
# The Subject's Distinguished Name is as follows
# commonName            :ASN.1 12:'rmq_client.cloud'
# Certificate is to be certified until Jan 27 14:58:35 2034 GMT (3652 days)
# Write out database with 1 new entries
# Data Base Updated


# view cn
openssl x509 -noout -subject -in ./client/client_certificate.pem

subject=CN = rmq_client.cloud

# view extensions
openssl x509 -noout -ext keyUsage < ./client/client_certificate.pem
# X509v3 Key Usage:
#    Digital Signature, Non Repudiation, Key Encipherment

openssl x509 -noout -ext extendedKeyUsage < ./client/client_certificate.pem
# X509v3 Extended Key Usage:
#    TLS Web Server Authentication, TLS Web Client Authentication, Code Signing, E-mail Protection

# cp to windows import in certificate
cat ./client/client_certificate.pem
# import in windows as client_certificate.crt
# Intended purposes = all

# all files
/rmq-x2-ssl/cert-store ls
ca_certificate.cer  certs   index.txt       index.txt.old  private  serial.old
ca_certificate.pem  client  index.txt.attr  openssl.cnf    serial

# server (client)
cd client
ls
client_certificate.pem  private_key.pem  req.pem
cd ..
cd certs
ls
01.pem

```

## Certificates for server (server) rmq_server.cloud

rmq_server.cloud

```bash
cd cert-store
mkdir server

# Generating RSA private key
openssl genrsa -out ./server/private_key.pem 2048

# Generating request
openssl req -new -key ./server/private_key.pem -out ./server/req.pem -outform PEM -subj /CN=rmq_server.cloud -nodes

# Server and client extension
openssl ca -config openssl.cnf -in ./server/req.pem -out ./server/server_certificate.pem -notext -batch  -extensions client_server_extension

# Using configuration from openssl.cnf
# Check that the request matches the signature
# Signature ok
# The Subject's Distinguished Name is as follows
# commonName            :ASN.1 12:'rmq_server.cloud'
# Certificate is to be certified until Jan 27 15:03:23 2034 GMT (3652 days)
# Write out database with 1 new entries
# Data Base Updated

# view cn
openssl x509 -noout -subject -in ./server/server_certificate.pem

subject=CN = rmq_server.cloud

# view extensions 
openssl x509 -noout -ext keyUsage < ./server/server_certificate.pem
# X509v3 Key Usage:
#    Digital Signature, Non Repudiation, Key Encipherment

openssl x509 -noout -ext extendedKeyUsage < ./server/server_certificate.pem
# X509v3 Extended Key Usage:
#    TLS Web Server Authentication, TLS Web Client Authentication, Code Signing, E-mail Protection

# server (server)
cd client
ls
private_key.pem  req.pem  server_certificate.pem
cd ..
cd certs
ls
01.pem  02.pem
```

## Make bundle and copy all certificates

We use the CA with just one cert as the bundle for each server, snice client and server cert was signed with the same CA.

```bash
cp cert-store/ca_certificate.pem ca.bundle

```



