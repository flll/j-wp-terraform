#!/bin/bash -e
set -o pipefail
cd `dirname $0`

echo "インスタンス名(サーバー名 web名ではありません)を入力してください"
echo "何も入力しない場合は\"web-instancwe\"という名前になります"
read -p "インスタンス名 > " CLI_OCI_LAUNCH_INSTANCE_NAME


#init
bash init/create-key.bash
. init/func.bash

echo -n "env Declaration... "
    oci-get-region-ocid
    oci-get-compartment-ocid
    oci-get-ad-ocid
echo "DONE"

oci-once-open-http-port

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
    --display-name "${CLI_OCI_LAUNCH_INSTANCE_NAME:-'wordpress-instance'}" \
    --user-data-file "init/cloud-config" \
    --ssh-authorized-keys-file ~/.oci/oci-key-public-ssh \
    --image-id ${CLI_OCI_IMAGE} \
    | jq -r '.data.id' \
        > instanceid-stdin
echo "DONE"

export aiueo=`cat instanceid-stdin`
(
rm -f instanceid-stdin
echo "IPアドレスを取得しています...."
echo "40秒間そのままお待ち下さい"
)&
sleep 40
oci compute instance list-vnics \
    --compartment-id ${CLI_OCI_COMPARTMENTID} \
    --instance-id $aiueo \
    --query 'data[].{"名前":"display-name", "ＩＰアドレス":"public-ip"}' \
    --output table
