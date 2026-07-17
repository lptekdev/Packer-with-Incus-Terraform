variable "incus_remote_name" {
  description = ""
  type        = string
  default     = ""
}

variable "incus_address" {
  type    = string
  default = "https://IP_INCUS_HOST:8443"
}

variable "golden_image_fingerprint" {
  type    = string
  default = ""
}
