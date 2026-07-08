terraform {
  required_version = ">= 1.5.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.206.0"
    }
  }

  backend "s3" {
    endpoints = {
      s3 = "https://plmsg.site:9000"
    }
    use_path_style              = true
    region                      = "ru-central1-a"
    bucket                      = "terraform"
    key                         = "terraform/terraform.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}