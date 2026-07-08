resource "yandex_alb_load_balancer" "task6_load_balancer" {
  name               = "task6-load-balancer"
  folder_id          = var.folder_id
  network_id         = yandex_vpc_network.task6_network.id
  security_group_ids = [yandex_vpc_security_group.task6_alb_security_group.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.task6_subnet.id
    }
  }

  listener {
    name = "task6-http-listener"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }
    http {
      redirects {
        http_to_https = true
      }
    }
  }

  listener {
    name = "task6-https-listener"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [443]
    }
    tls {
      default_handler {
        certificate_ids = [yandex_cm_certificate.task6_certificate.id]
        http_handler {
          http_router_id = yandex_alb_http_router.task6_http_router.id
        }
      }
    }
  }
}
