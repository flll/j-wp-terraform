#!/bin/bash -e
set -o pipefail
cd `dirname $0`

#init
bash init/create-key.bash

echo -n "env Declaration... "
declare -A CLI_OCI_IMAGEMAP
CLI_OCI_IMAGEMAP=(
    ["ap-tokyo-1"]="ocid1.image.oc1.ap-tokyo-1.aaaaaaaacmmicmlaejkkorfp5es7r6h4hfi5zxupz3muxchksgkugztkl4ea"
    ["ap-osaka-1"]="ocid1.image.oc1.ap-osaka-1.aaaaaaaamcrmkxuvsk4coctz5jtsdbtoiin4xvvjo6zceonlib57eiliaupa"
)
export CLI_OCI_IMAGE=${CLI_OCI_IMAGEMAP[$OCI_REGION]}
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
    --user-data-file "init/init-instance.bash" \
    --ssh-authorized-keys-file ~/.oci/oci-key-public-ssh \
    --image-id $CLI_OCI_IMAGE | jq -r '.data.id' > instanceid-stdin
echo "DONE"
export aiueo=`cat instanceid-stdin`
(
rm -f instanceid-stdin
echo "IPアドレスを取得しています...."
echo "40秒間そのままお待ち下さい"
)&
sleep 40
oci compute instance list-vnics --compartment-id ${CLI_OCI_COMPARTMENTID} --instance-id $aiueo --query 'data[].{"名前":"display-name", "ＩＰアドレス":"public-ip"}' --output table
