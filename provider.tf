provider "oci" {
  auth = "InstancePrincipal"
  region = var.region
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

output "show-ads" {
  value = data.oci_identity_availability_domains.ads.availability_domains
}
