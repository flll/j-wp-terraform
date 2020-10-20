provider "oci" {
  tenancy_ocid = "var.tenancy_ocid"
  user_ocid = "var.user_ocid"
  fingerprint = "var.fingerprint"
  private_key_path = "var.private_key_path"
}

output "InstancePublicIP" {
  value = ["oci_core_instance.wp_instance.*.public_ip"]
}
