packer {
  required_plugins {
    incus = {
      source  = "github.com/bketelsen/incus"
      version = "~> 1"
    }
    ansible = {
      version = "~> 1"
      source = "github.com/hashicorp/ansible"
    }
  }
}

variable "app_source_dir" {
  type        = string
  description = "Path to the application source directory"
}



variable "vm_name" {
  type        = string
  description = "The vm name"
  default     = "ubuntu-template"
}


variable "incus_name" {
  type        = string
  description = "The Incus remote name"
}


source "incus" "incus-xenial" {
  image = "images:ubuntu/26.04/cloud"
  output_image = "${var.incus_name}:${var.vm_name}"
  virtual_machine = true
  publish_remote_name = "${var.incus_name}"
  init_sleep = "90"
  container_name = "${var.vm_name}"
}



build {
  sources = ["source.incus.incus-xenial"]
  provisioner "ansible" {
    extra_arguments = [
      "-vv",
      "-e","app_source_dir=${var.app_source_dir}",
      "-e","vm_name=${var.vm_name}",
      "-e","ansible_connection=community.general.incus",
      "-e","ansible_incus_remote=${var.incus_name}",
      "-e","ansible_incus_project=default",
      "-e","ansible_host=ubuntu-template"
    ]
    ansible_env_vars = [ "ANSIBLE_HOST_KEY_CHECKING=False" ]
    use_proxy     = false
    playbook_file = "./ansible/main-playbook.yml"
    timeout = "10m"

  }
}

