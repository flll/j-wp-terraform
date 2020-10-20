#!/bin/bash -e -o pipefail

if [ ! -d ~/.oci ]; then
	mkdir ~/.oci
fi
	openssl version
if [ ! -e ~/.oci/oci-api-key.pem ]; then
	openssl genrsa -out ~/.oci/oci-api-key.pem 4096
	chmod go-rwx ~/.oci/oci-api-key.pem
	openssl rsa -pubout -in ~/.oci/oci-api-key.pem -out ~/.oci/oci-api-key-public.pem
fi

export TF_VAR_compartment_ocid=`oci iam compartment list | jq -r '.data[].id'`
export TF_VAR_tenancy_ocid=$OCI_TENANCY
export IDentity_provider=`oci iam identity-provider list -c $TF_VAR_tenancy_ocid --protocol SAML2 | jq -r '.data[].id'`
export TF_VAR_user_ocid=`oci iam user list --identity-provider-id $IDentity_provider | jq -r '.data[].id'`
export TF_VAR_private_key_path="~/.oci/oci-api-key.pem"
export TF_VAR_fingerprint=`openssl rsa -pubout -outform DER -in ~/.oci/oci-api-key.pem | openssl md5 -c | sed -e 's/(stdin)= //'`
export TF_VAR_region=$OCI_REGION
export TF_VAR_ssh_public_key=`ssh-keygen -f ~/.oci/oci-api-key-public.pem -i -mPKCS8`

echo 123456789 END
