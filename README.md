# Packer with Incus + Terraform + Gitlab pipeline

## Packer with Incus and Gitlab pipeline
The Packer folder contains the files for a pipeline in Gitlab that uses Packer to create a golden image in an Incus host.
**The cloud init (user-data and network) is applied based on Default profile in Incus, in the Default project.**

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

The main idea is use this Golden image to create a K3S cluster using two OVN networks that are peered between each other to allow subnet segmentation and also the communication within the Masters and Workers. There are also ACLs configuration to increase the security level between the two subnets. Be aware that the underlying network configuration with BGP required to use pre-defined IPv4 address space in OVN networks is not here described. In the network Terraform file consider the address subnets as an example that depends of your network configuration for the [Incus External Physical network](https://linuxcontainers.org/incus/docs/main/reference/network_physical/).

This is just an example, feel free to clone and add/recplace with your improvements.