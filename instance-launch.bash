#!/bin/bash -e
set -o pipefail
cd `dirname $0`

#init
bash init/create-key.bash
. init/func.bash

echo -n "env Declaration... "
    oci-get-region-ocid
    oci-get-compartment-ocid
    oci-get-ad-ocid
echo "DONE"



## インスタンスの取得
echo -n "Instance Launch... "
oci compute instance launch \
    --availability-domain ${CLI_OCI_AD}\
    --compartment-id ${CLI_OCI_COMPARTMENTID} \
    --shape "VM.Standard.E2.1.Micro" \
    --subnet-id `oci network subnet list \
            -c ${CLI_OCI_COMPARTMENTID} \
            --sort-by TIMECREATED \
            --sort-order ASC \
            | jq -r '.data[0].id'` \
    --assign-public-ip true \
    --display-name "Wordpress Instance" \
    --user-data-file "init/cloud-config" \
    --ssh-authorized-keys-file ~/.oci/oci-key-public-ssh \
    --image-id ${CLI_OCI_IMAGE} \
    | jq -r '.data.id' > instanceid-stdin
echo "DONE"

export aiueo=`cat instanceid-stdin`
(
rm -f instanceid-stdin
echo "IPアドレスを取得しています...."
echo "40秒間そのままお待ち下さい"
)&
sleep 40
oci compute instance list-vnics --compartment-id ${CLI_OCI_COMPARTMENTID} --instance-id $aiueo --query 'data[].{"名前":"display-name", "ＩＰアドレス":"public-ip"}' --output table
