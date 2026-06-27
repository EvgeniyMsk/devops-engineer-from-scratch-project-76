variable "home_ip" {
  type        = string
  description = "Home IP address"
  default     = "89.124.73.57/32"
}

variable "office_ip" {
  type        = string
  description = "Office IP address"
  default     = "178.177.19.99/32"
}

variable "folder_id" {
  type        = string
  description = "Folder ID"
  default     = "b1gepvj6lg03dc9505kh"
}

locals {
  ssh_public_key = trimspace(file(pathexpand("~/.ssh/id_rsa.pub")))
}