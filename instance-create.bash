#!/bin/bash -e
set -o pipefail
cd `dirname $0`

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

declare -A CLI_OCI_IMAGEMAP

CLI_OCI_IMAGEMAP=(
    ["ap-tokyo-1"]="ocid1.image.oc1.ap-tokyo-1.aaaaaaaa2lb55favhw7mhirylv4pniqu3oxpmoyjbrtfank4kdleiflfqbta"
    ["ap-osaka-1"]="ocid1.image.oc1.ap-osaka-1.aaaaaaaaevxg6tpchgyijcdjlzcflkat5ndpsfy6n3tjois2qe3yrtrjrnlq"
)
export CLI_OCI_IMAGE=${CLI_OCI_IMAGEMAP[$OCI_REGION]}

oci compute instance launch \
    --compartment-id `oci iam compartment list | jq -r '.data[]."compartment-id"'` \
    --shape VM.Standard2.1 \
    --subnet-id `oci network subnet list  -c `oci iam compartment list | jq -r '.data[]."compartment-id"'` --sort-by TIMECREATED --sort-order ASC | jq -r '.data[0].id'` \
    --assign-public-ip true \
    --display-name "Wordpress Instance" \
    --user-data-file "./cloud-config" \
    --ssh-authorized-keys-file "~/.oci/oci-api-key-public.pem" \
    --image-id $CLI_OCI_IMAGE 
