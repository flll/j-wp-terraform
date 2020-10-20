provider "oci" {
  tenancy_ocid = "var.tenancy_ocid"
  user_ocid = "var.user_ocid"
  fingerprint = "var.fingerprint"
  private_key_path = "var.private_key_path"
  region = "var.region"
}

output "InstancePublicIP" {
  value = ["oci_core_instance.test_instance.*.public_ip"]
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = "var.tenancy_ocid"
}
