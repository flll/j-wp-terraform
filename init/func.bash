#!/bin/bash

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
## //CLI_OCI_AD// ADのOCIDを取得
#  depend-var: CLI_OCI_COMPARTMENTID
[[ ! -f .DONE_add_http-gate ]] && exit 0
    function kid () {
	export securitylist_add_http=$(jq -c <<-'EOF'
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
	) && touch .DONE_add_http-gate ## oci-once-open-http-portで何度もアペンドしないようにファイルを追加
    }

    ## 一番古く作られたサブネットを参照
    CLI_OCI_SUBNETID=`oci network subnet list \
        -c $CLI_OCI_COMPARTMENTID \
        --sort-by TIMECREATED \
        --sort-order ASC \
        | jq -r '.data[0].id'`

    ## サブネットの情報を確認し、”セキュリティリストIDを取得”する。セキュリティIDはどれでも構わない
    # dedpend
    CLI_OCI_SECURITY_LISTID=`oci network subnet get 
        --subnet-id ${CLI_OCI_SUBNETID} \
        | jq -r '.data."security-list-ids"[0]'`
    #↓未完成
    oci network security-list update \
            --security-list-id ${CLI_OCI_SECURITY_LISTID}
    oci network security-list get \
            --security-list-id ${CLI_OCI_SECURITY_LISTID}

    --ingress-security-rules $securitylist_add_http
    

}