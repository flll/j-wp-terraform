#!/bin/bash -e
set -o pipefail
cd `dirname $0`

export TF_VAR_num_instances="1"
export TF_VAR_instance_shape="VM.Standard2.1"
export TF_VAR_instance_display_name="WordPressInstance"

terraform init
terraform plan -out="wp-p"
terraform apply "wp-p"
terraform output public_ip
