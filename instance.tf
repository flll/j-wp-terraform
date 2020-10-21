// Copyright (c) 2017, 2020, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Mozilla Public License v2.0

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
    source_id   = var.flex_instance_image_ocid[var.region]
  }
  create_vnic_details {
    subnet_id        = oci_core_subnet.wp_subnet.id
    display_name     = "Primaryvnic"
    assign_public_ip = true
  }
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = filebase64("${path.module}/cloud-config")
  }
  timeouts {
    create = "60m"
  }
}

resource "oci_core_vcn" "wp_vcn" {
  cidr_block     = "10.5.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "wp_vcn"
  dns_label      = "wp_vcn"
}

resource "oci_core_internet_gateway" "wp_internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "WPInternetGateway"
  vcn_id         = oci_core_vcn.wp_vcn.id
}

resource "oci_core_default_route_table" "default_route_table" {
  manage_default_resource_id = oci_core_vcn.wp_vcn.default_route_table_id
  display_name               = "DefaultRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.wp_internet_gateway.id
  }
}

resource "oci_core_subnet" "wp_subnet" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  cidr_block          = "10.5.50.0/24"
  display_name        = "wp_subnet"
  dns_label           = "wordpress_subnet"
  security_list_ids   = [oci_core_vcn.wp_vcn.default_security_list_id]
  compartment_id      = var.compartment_ocid
}

resource "oci_core_subnet" "wp_subnet" {
  cidr_block          = "10.5.50.0/24"
  display_name        = "wp_subnet"
  dns_label           = "wp_subnet"
  security_list_ids   = [oci_core_vcn.wp_vcn.default_security_list_id]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.wp_vcn.id
}
