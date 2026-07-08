resource "yandex_cm_certificate" "task6_certificate" {
  name        = "task6-certificate"
  description = "TLS certificate for task6.devops-campus.ru"
  folder_id   = var.folder_id

  self_managed {
    certificate = file(var.certificate_path)
    private_key = file(var.private_key_path)
  }
}
