resource "incus_network" "ovn_k3s_masters" {
 depends_on = [
    incus_network_acl.k3s-master-acl
  ]
  name = "ovn_k3s_masters"
  type = "ovn"
  description = "k3s master network"

  config = {
    "ipv4.address" = "10.13.1.1/24"
    "ipv4.nat"     = "false"
    "ipv4.dhcp" = "true"
    "ipv4.dhcp.ranges" = "10.13.1.4-10.13.1.253"
    "network" = "uplink-505" // this network configuration is not included in this repo
    "ipv6.address" = "none"
    "security.acls.default.egress.action" = "allow"
    "security.acls.default.ingress.action" = "drop"
    "security.acls" = "k3s-master-acl"
  }
}

resource "incus_network" "ovn_k3s_worker" {
depends_on = [
    incus_network_acl.k3s-master-acl
  ]
  name = "ovn_k3s_worker"
  type = "ovn"
  description = "k3s workers network"

  config = {
    "ipv4.address" = "10.13.2.1/24"
    "ipv4.nat"     = "false"
    "ipv4.dhcp" = "true"
    "ipv4.dhcp.ranges" = "10.13.2.4-10.13.2.253"
    "network" = "uplink-505" // this network configuration is not included in this repo
    "ipv6.address" = "none"
    "security.acls.default.egress.action" = "allow"
    "security.acls.default.ingress.action" = "drop"
    "security.acls" = "k3s-master-acl"
  }
}


resource "incus_network_peer" "ovn_k3s_masters_ovn_k3s_worker"{
  depends_on = [
    incus_network.ovn_k3s_masters,
    incus_network.ovn_k3s_worker
  ]
  name           = "ovnk3smasters-ovnk3sworker"
  description    = ""
  network        = incus_network.ovn_k3s_masters.name
  project        = "default"
  target_network = incus_network.ovn_k3s_worker.name
  target_project = "default"
 }

resource "incus_network_peer" "ovn_k3s_worker_ovn_k3s_masters"{
  depends_on = [
    incus_network.ovn_k3s_masters,
    incus_network.ovn_k3s_worker
  ]
  name           = "ovnk3smasters-ovnk3sworker"
  description    = ""
  network        = incus_network.ovn_k3s_worker.name
  project        = "default"
  target_network = incus_network.ovn_k3s_masters.name
  target_project = "default"
}