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

variable "domain_name" {
  type        = string
  description = "Application domain name"
  default     = "task6.devops-campus.ru"
}

variable "certificate_path" {
  type        = string
  description = "Path to TLS certificate file"
  default     = "certs/cert.pem"
}

variable "private_key_path" {
  type        = string
  description = "Path to TLS private key file"
  default     = "certs/key.pem"
}

variable "redmine_db_password" {
  type        = string
  description = "PostgreSQL password for Redmine user"
  sensitive   = true
}

locals {
  ssh_public_key = trimspace(file(pathexpand("~/.ssh/id_rsa.pub")))
}