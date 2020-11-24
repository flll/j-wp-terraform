#!/bin/bash
##
#  depend ../で実行すること

function oci-get-region-ocid () {
    declare -A CLI_OCI_IMAGEMAP
    # Canonical-Ubuntu-20.04-Minimal-2020.10.14-0
    CLI_OCI_IMAGEMAP=(
        ["ap-tokyo-1"]="ocid1.image.oc1.ap-tokyo-1.aaaaaaaadp4m22caz42cbuuessijfriormbaosmxogofn3zhuwfirnglzqza"
        ["ap-osaka-1"]="ocid1.image.oc1.ap-osaka-1.aaaaaaaazktg245a6iyvs3ns7hsptebrqzeopclx5nzhoutfgt6zyltvngza"
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
    echo -n "firewall updating... "
    function kid () {
        ## 下のEOFの部分はTABインデントであること
        securitylist_add_http=`jq -c '' <<-'EOF'
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
            },
            {
                "source": "0.0.0.0/0",
                "description": null,
                "icmp-options": null,
                "protocol": "6",
                "isStateless": true,
                "tcpOptions": {
                    "destinationPortRange": {
                        "max": 22,
                        "min": 22
                    },
                    "sourcePortRange": null
                }
            }
        ]
		EOF
        `
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
    kid
    oci network security-list update \
            --security-list-id ${CLI_OCI_SECURITY_LISTID} \
            --force \
            --ingress-security-rules $securitylist_add_http
    unset kid
echo "DONE"
}