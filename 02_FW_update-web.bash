#!/bin/bash -e
set -o pipefail
cd `dirname $0`

echo "最も古く作られたoci-VCNのFW-listを置き換えます"
echo "書き換えてしまうため、追加でFWを設定している場合この処理を行わないでください。"
echo "キャンセルする場合はctrl + cを入力してください。"
read -p "続行する場合このままエンターキーを入力してください。" a

oci-get-compartment-ocid
oci-once-open-http-port