resource "incus_profile" "k3s_masters_profile" {
  depends_on = [
    incus_network.ovn_k3s_masters,
    incus_network.ovn_k3s_worker,
  ]
  name = "k3s_masters_profile"

  device {
    name = "eth0"
    type = "nic"

    properties = {
        network = incus_network.ovn_k3s_masters.name
    }
   }

  device {
    type = "disk"
    name = "root"

    properties = {
      pool = "default"
      path = "/"
      size = "42949672960" //40GB
    }
  }
}
