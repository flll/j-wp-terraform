// Copyright (c) 2017, 2020, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Mozilla Public License v2.0

# Configure the Oracle Cloud Infrastructure provider to use Instance Principal based authentication
provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  config_file_profile= "/etc/oci/config"
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = 1
}
output "public_ip" {
  value = ["oci_core_instance.wp_instance.*.public_ip"]
}
