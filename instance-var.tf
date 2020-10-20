variable "NumInstances"{
  default = "1"
}
variable "instance_shape" {
  default = "VM.Standard2.1"
}
variable "instance_image_ocid" {
  type = map(string)
  default = {
    ap-tokyo-1 = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaa2lb55favhw7mhirylv4pniqu3oxpmoyjbrtfank4kdleiflfqbta"
    ap-osaka-1 = "ocid1.image.oc1.ap-osaka-1.aaaaaaaaevxg6tpchgyijcdjlzcflkat5ndpsfy6n3tjois2qe3yrtrjrnlq"
  }
}
