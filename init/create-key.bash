#!/bin/bash
[ ! -d ~/.oci ] && mkdir ~/.oci
if [ ! -e ~/.oci/oci-key.pem ]; then
    echo -n "key-pairing...  "
    openssl genrsa -out ~/.oci/oci-key.pem 2048
    chmod go-rwx ~/.oci/oci-key.pem
    openssl rsa -in  ~/.oci/oci-key.pem -pubout \
                -out ~/.oci/oci-key-public.pem
    ssh-keygen -f ~/.oci/oci-key-public.pem -i -mPKCS8 \
                > ~/.oci/oci-key-public-ssh
    echo "DONE"
fi
