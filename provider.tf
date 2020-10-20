provider "oci" {
  tenancy_ocid = "var.tenancy_ocid"
  user_ocid = "var.user_ocid"
  fingerprint = "var.fingerprint"
  private_key_path = "var.private_key_path"
  region = "var.region"
  ssh_public_key = "var.ssh_public_key"
}

output "InstancePublicIP" {
  value = ["oci_core_instance.test_instance.*.public_ip"]
}
