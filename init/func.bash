#!/bin/bash
##
#  depend ../で実行すること

function oci-get-region-ocid () {
    declare -A CLI_OCI_IMAGEMAP
    CLI_OCI_IMAGEMAP=(
        ["ap-tokyo-1"]="ocid1.image.oc1.ap-tokyo-1.aaaaaaaacmmicmlaejkkorfp5es7r6h4hfi5zxupz3muxchksgkugztkl4ea"
        ["ap-osaka-1"]="ocid1.image.oc1.ap-osaka-1.aaaaaaaamcrmkxuvsk4coctz5jtsdbtoiin4xvvjo6zceonlib57eiliaupa"
    )
    ## //CLI_OCI_IMAGE// 定義されたOCIDイメージマップから取得
    export CLI_OCI_IMAGE=${CLI_OCI_IMAGEMAP[$OCI_REGION]}
}

function oci-get-compartment-ocid () {
    ## //CLI_OCI_COMPARTMENTID// コンパートメントOCIDを取得
    export CLI_OCI_COMPARTMENTID=`oci iam compartment list \
        | jq -r '.data[]."compartment-id"'`
}

function oci-get-ad-ocid () {
    ## //CLI_OCI_AD// ADのOCIDを取得
    #  depend-var: CLI_OCI_COMPARTMENTID
    export CLI_OCI_AD=`oci iam availability-domain list \
        --compartment-id ${CLI_OCI_COMPARTMENTID} \
        | jq -r '.data[].name'`
}

function oci-once-open-http-port () {
    [[ -f init/.DONE_add_http-gate ]] && return;
    echo -n "firewall updating... "
    function kid () {
        ## 下のjsonの部分はTABインデントであること
        securitylist_add_http=(jq -c << 'EOF'
        [
            {
                "source": "0.0.0.0/0",
                "description": null,
                "icmp-options": null,
                "protocol": "6",
                "isStateless": true,
                "tcpOptions": {
                    "destinationPortRange": {
                        "max": 80,
                        "min": 80
                    },
                    "sourcePortRange": null
                }
            },
            {
                "source": "0.0.0.0/0",
                "description": null,
                "icmp-options": null,
                "protocol": "6",
                "isStateless": true,
                "tcpOptions": {
                    "destinationPortRange": {
                        "max": 443,
                        "min": 443
                    },
                    "sourcePortRange": null
                }
            }
        ]
EOF
        ) && touch init/.DONE_add_http-gate ## oci-once-open-http-portで何度もアペンドしないようにファイルを追加。このファイルが存在すると変
    }

    ## 一番古く作られたサブネットを参照
    #  depend-var \$CLI_OCI_COMPARTMENTID
    CLI_OCI_SUBNETID=`oci network subnet list \
        -c ${CLI_OCI_COMPARTMENTID} \
        --sort-by TIMECREATED \
        --sort-order ASC \
        | jq -r '.data[0].id'`

    ## セキュリティリストOCIDを取得する。複数ある場合どれでも構わない
    # dedpend-var \$CLI_OCI_SUBNETID
    CLI_OCI_SECURITY_LISTID=`oci network subnet get \
        --subnet-id ${CLI_OCI_SUBNETID} \
        | jq -r '.data."security-list-ids"[0]'`
    echo kidkid
    kid
    oci network security-list update \
            --security-list-id ${CLI_OCI_SECURITY_LISTID} \
            --force \
            --ingress-security-rules $securitylist_add_http
    unset kid
echo "DONE"
}