resource "yandex_alb_http_router" "task6_http_router" {
  name          = "task6-http-router"
  folder_id = var.folder_id
  labels        = {
    environment = "production"
  }
}

resource "yandex_alb_virtual_host" "task6_virtual_host" {
  name           = "task6-virtual-host"
  http_router_id = yandex_alb_http_router.task6_http_router.id
  
  rate_limit {
    all_requests {
      per_second = 100
      # или per_minute = <количество_запросов_в_минуту>
    }
    requests_per_ip {
      per_second = 100
      # или per_minute = <количество_запросов_в_минуту>
    }
  }

  route {
    name                      = "task6-route"
    disable_security_profile  = true

    http_route {
      http_match {
        http_method = ["GET", "POST", "PUT", "DELETE"]
        path {
          prefix = "/"
        }
      }

      http_route_action {
        backend_group_id  = yandex_alb_backend_group.task6_backend_group.id
        host_rewrite      = var.domain_name
        timeout           = "10s"
        idle_timeout      = "10s"
        prefix_rewrite    = "/"
        rate_limit {
          all_requests {
            per_second = 100
            # или per_minute = <количество_запросов_в_минуту>
          }
          requests_per_ip {
            per_second = 100
            # или per_minute = <количество_запросов_в_минуту>
          }
        }
      }
    }
  }

  authority        = [var.domain_name]
}