// Copyright (c) 2017, 2020, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Mozilla Public License v2.0

variable "tenancy_ocid" {}
variable "region" {}
variable "compartment_ocid" {}
variable "ssh_public_key" {}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  region           = var.region
}
variable "num_instances" {
  default = "1"
}

variable "num_iscsi_volumes_per_instance" {
  default = "1"
}

variable "instance_shape" {
  default = "VM.Standard2.1"
}
variable "flex_instance_image_ocid" {
  type = map(string)
  default = {
    ap-tokyo-1 = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaa2lb55favhw7mhirylv4pniqu3oxpmoyjbrtfank4kdleiflfqbta"
    ap-osaka-1 = "ocid1.image.oc1.ap-osaka-1.aaaaaaaaevxg6tpchgyijcdjlzcflkat5ndpsfy6n3tjois2qe3yrtrjrnlq"
  }
}

resource "oci_core_instance" "wp_instance" {
  compartment_id      = var.compartment_ocid
  display_name        = var.instance_display_name
  shape               = var.instance_shape
  count               = var.num_instances
  availability_domain = data.oci_identity_availability_domain.ad.name
  source_details {
    source_type = "image"
    source_id = var.flex_instance_image_ocid[var.region]
  }
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = filebase64("${path.module}/cloud-config")
  }
  timeouts {
    create = "60m"
  }
}
data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = 1
}
output "public_ip" {
  value = ["oci_core_instance.wp_instance.*.public_ip"]
}
