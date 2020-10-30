#!/bin/bash
if [ ! -d ~/.oci ]; then
    mkdir ~/.oci
    echo -n "mkdir done  "
fi
if [ ! -e ~/.oci/oci-key.pem ]; then
    echo -n "key-creating...  "
    openssl genrsa -out ~/.oci/oci-key.pem 4096
    chmod go-rwx ~/.oci/oci-key.pem
    openssl rsa -pubout -in ~/.oci/oci-key.pem -out ~/.oci/oci-key-public.pem
    ~/.oci/oci-key-public-ssh
    ssh-keygen -f ~/.oci/oci-key-public.pem -i -mPKCS8 > ~/.oci/oci-key-public-ssh
    echo -n "done  "
fi
