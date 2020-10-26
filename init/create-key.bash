#!/bin/bash
if [ ! -d ~/.oci ]; then
    mkdir ~/.oci
    echo -n "mkdir done  "
fi
if [ ! -e ~/.oci/oci-api-key.pem ]; then
    echo -n "key-creating...  "
    openssl genrsa -out ~/.oci/oci-api-key.pem 4096
    chmod go-rwx ~/.oci/oci-api-key.pem
    openssl rsa -pubout -in ~/.oci/oci-api-key.pem -out ~/.oci/oci-api-key-public.pem
    echo -n "done  "
fi
echo "done create-key"
