#!/bin/bash -e
set -o pipefail

export CLI_OCI_COMPARTMENTID=`oci iam compartment list | jq -r '.data[]."compartment-id"'`
export CLI_OCI_AD=`oci iam availability-domain list --compartment-id ${CLI_OCI_COMPARTMENTID} | jq -r '.data[].name'`
export CLI_OCI_INSTANCE_OCID=`oci compute instance list --compartment-id ${CLI_OCI_COMPARTMENTID} --availability-domain ${CLI_OCI_AD} --sort-by TIMECREATED --sort-order DESC | jq -r '.data[0].id'`

oci compute instance terminate --instance-id ${CLI_OCI_INSTANCE_OCID} 

