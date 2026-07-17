resource "incus_network_acl" "k3s-master-acl" {
  name = "k3s-master-acl"

  ingress = [
     {
      action           = "allow"
      source           = ""
      destination_port = ""
      protocol         = "icmp4"
      description      = "allow ICMP"
      state            = "enabled"
    },
    {
      action           = "drop"
      source           = "10.13.2.0/24"
      destination_port = "22"
      protocol         = "tcp"
      description      = "Incoming SSH connections from workers"
      state            = "enabled"
    },
    {
      action           = "allow"
      source           = ""
      destination_port = "22"
      protocol         = "tcp"
      description      = "Incoming SSH connections"
      state            = "enabled"
    },

    {
      action           = "allow"
      source           = ""
      destination_port = "6443"
      protocol         = "tcp"
      description      = "Allow API access"
      state            = "enabled"
    },
    {
      action           = "allow"
      source           = "10.13.1.0/24,10.13.2.0/24"
      destination_port = "8472"
      protocol         = "udp"
      description      = "Allow Flannel network overlay"
      state            = "enabled"
    },
    {
      action           = "allow"
      source           = "10.13.1.0/24,10.13.2.0/24"
      destination_port = "10250"
      protocol         = "tcp"
      description      = "Allow kubelet communication"
      state            = "enabled"
    },
    {
      action           = "allow"
      source           = "10.13.1.0/24"
      destination_port = "2379-2380"
      protocol         = "tcp"
      description      = "Allow control plane communication"
      state            = "enabled"
    }
  ]
}
