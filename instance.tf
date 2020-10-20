resource "oci_core_instance" "test_instance" {
  count               = var.num_instances
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = var.instance_display_name
  shape               = var.instance_shape
  source_details {
    source_id = var.instance_image_ocid[var.region]
    source_type = "image"
  }
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = "base64encode(file("cloud-config"))"
  }
  timeouts {
    create = "60m"
  }
}
