terraform {
  required_providers {
    incus = {
      source = "lxc/incus"
    }
  }
}

provider "incus" {
  generate_client_certificates = false
  accept_remote_certificate    = true
  default_remote               = var.incus_remote_name


  remote {
    name    = var.incus_remote_name
    address = var.incus_address
  }
}


resource "incus_instance" "instance1" {
  depends_on = [
    incus_network.ovn_k3s_masters,
    incus_network.ovn_k3s_worker,
    incus_network_acl.k3s-master-acl,
    incus_profile.k3s_masters_profile
  ]
  name  = "instance1"
  image = var.golden_image_fingerprint
  type    = "virtual-machine"
  profiles  = ["${incus_profile.k3s_masters_profile.name}"]


}