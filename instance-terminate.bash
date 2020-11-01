#!/bin/bash -e
set -o pipefail

echo "削除したいインスタンスは起動しておいてください。"
echo "一番最近に作成されたインスタンスを削除します。"
echo "しばらくお待ち下さい..." 
export CLI_OCI_COMPARTMENTID=`oci iam compartment list | jq -r '.data[]."compartment-id"'`
export CLI_OCI_AD=`oci iam availability-domain list --compartment-id ${CLI_OCI_COMPARTMENTID} | jq -r '.data[].name'`
export CLI_OCI_INSTANCE_OCID=`oci compute instance list --compartment-id ${CLI_OCI_COMPARTMENTID} --availability-domain ${CLI_OCI_AD} --sort-by TIMECREATED --sort-order DESC --lifecycle-state RUNNING | jq -r '.data[0].id'`

oci compute instance get --instance-id ${CLI_OCI_INSTANCE_OCID} --query 'data.{"名前":"display-name"}' --output table 
(
echo "削除するインスタンスの確認をお願いします。"
echo "数秒お待ち下さい..."
sleep 3
echo "\"Y\"[はい] もしくは\"N\"[拒否]のちエンターの入力をお願いします"
)&
oci compute instance terminate --instance-id ${CLI_OCI_INSTANCE_OCID} 
