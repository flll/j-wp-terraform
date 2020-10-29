#!/bin/bash -e
set -o pipefail
cd `dirname $0`

#init
bash init/create-key.bash

declare -A CLI_OCI_IMAGEMAP

CLI_OCI_IMAGEMAP=(
    ["ap-tokyo-1"]="ocid1.image.oc1.ap-tokyo-1.aaaaaaaa2lb55favhw7mhirylv4pniqu3oxpmoyjbrtfank4kdleiflfqbta"
    ["ap-osaka-1"]="ocid1.image.oc1.ap-osaka-1.aaaaaaaar7ovad7pwnlsre6fk3ienut5bb522h32uctzxfk3ubwfm5hksx3q"
)

export CLI_OCI_IMAGE=${CLI_OCI_IMAGEMAP[$OCI_REGION]}
echo -n "env Declaration... "
export CLI_OCI_COMPARTMENTID=`oci iam compartment list | jq -r '.data[]."compartment-id"'`
export CLI_OCI_AD=`oci iam availability-domain list --compartment-id ${CLI_OCI_COMPARTMENTID} | jq -r '.data[].name'`
echo "DONE"

echo -n "Instance Launch... "
oci compute instance launch \
    --availability-domain ${CLI_OCI_AD}\
    --compartment-id ${CLI_OCI_COMPARTMENTID} \
    --shape "VM.Standard.E2.1.Micro" \
    --subnet-id `oci network subnet list -c $CLI_OCI_COMPARTMENTID --sort-by TIMECREATED --sort-order ASC | jq -r '.data[0].id'` \
    --assign-public-ip true \
    --display-name "Wordpress Instance" \
    --user-data-file "init/cloud-config" \
    --ssh-authorized-keys-file ~/.oci/oci-key-public-ssh \
    --image-id $CLI_OCI_IMAGE > instance.json
#jq -r '.data.id'
echo "DONE"

echo "IPアドレスを取得しています...."
echo "20秒間そのままお待ち下さい"
#oci compute instance list-vnics --compartment-id ${CLI_OCI_COMPARTMENTID} --instance-id 
