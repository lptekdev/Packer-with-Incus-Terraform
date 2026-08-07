# Packer with Incus + Terraform + Gitlab pipeline

## Packer with Incus and Gitlab pipeline
The Packer folder contains the files for a pipeline in Gitlab that uses Packer to create a golden image in an Incus host.
**The cloud init (user-data and network) is applied based on Default profile in Incus, in the Default project.**  

The variable: *init_sleep* is set to 90 seconds, because it's the enough time required for the cloud-init in Incus default profile to finish.

Be aware I'm using "ansible_connection=community.general.incus", for the Ansible Packer provisioner:
[Incus_Ansible](https://docs.ansible.com/projects/ansible/latest/collections/community/general/incus_connection.html)

In the pipeline there is a certificate and key (replace the AUTH_CERT.crt and AUTH_CERT.key with the name of your certificates) that are used to authenticate the Gitlab Runner in the Incus host. This certificate needs also to be added in Incus host like:

```
sudo incus config trust add-certificate AUTH_CERT.crt
```
```
sudo incus config trust list
+--------------------+--------+-------------+--------------+----------------------+
|        NAME        |  TYPE  | DESCRIPTION | FINGERPRINT  |     EXPIRY DATE      |
+--------------------+--------+-------------+--------------+----------------------+
| incus-ui.crt       | client |             | 52abca2150b6 | 2029/03/31 15:35 UTC |
+--------------------+--------+-------------+--------------+----------------------+
| AUTH_CERT.crt      | client |             | ee2a9d6d9e66 | 2027/07/05 16:43 UTC |
+--------------------+--------+-------------+--------------+----------------------+

```

## Terraform and Incus
In the Terraform folder you can find the files to create a VM based on the previous Golden image in an Incus host. Just populate the variables file to match your Incus host and the golden image fingerprint.
The same certificate and key can be also re-used and are required to be copied to the incus client configuration directory: *"$HOME/.config/incus/"* (although you can generate a new ones and add them like the previous commands). As in the pipeline, replace the names with *client.crt* and *client.key*.

The main idea is use this Golden image to create a K3S cluster using two OVN networks that are peered between each other to allow subnet segmentation and also the communication within the Masters and Workers. There are also ACLs configuration to increase the security level between the two subnets. In the network Terraform file consider the address subnets as an example that depends of your network configuration for the [Incus External Physical network](https://linuxcontainers.org/incus/docs/main/reference/network_physical/).

This is just an example, feel free to clone and add/replace with your improvements.

## OVN in Incus
After installing OVN package in the Incus host, below is an example how I connect the Incus host via BGP to my upstream routers. As you also can see, I have two vyos routers and I use VRRP for high availability of the gateway:

````
incus config set core.bgp_address=172.16.1.18:179
incus config set core.bgp_asn=64516
incus config set core.bgp_routerid=172.16.1.18

incus network create uplink-505 parent=enp4s0f0 vlan=505 ipv4.gateway=172.16.7.1/24 --type=physical
incus network set uplink-505 ipv4.ovn.ranges=172.16.7.10-172.16.7.253
incus network set uplink-505 ipv4.routes=10.13.0.0/16
incus network set uplink-505 bgp.peers.r11.address=172.16.7.2
incus network set uplink-505 bgp.peers.r11.asn=64513
incus network set uplink-505 bgp.peers.r12.address=172.16.7.3
incus network set uplink-505 bgp.peers.r12.asn=64513
````