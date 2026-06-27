resource "yandex_alb_backend_group" "task6_backend_group" {
  name      = "task6-backend-group"
  folder_id = var.folder_id
  http_backend {
    name             = "task6-backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.task6_target_group.id]
    healthcheck {
      timeout  = "1s"
      interval = "2s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}