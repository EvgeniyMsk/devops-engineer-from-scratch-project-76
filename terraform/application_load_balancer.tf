resource "yandex_alb_load_balancer" "task6_load_balancer" {
  name = "task6-load-balancer"
  folder_id = var.folder_id
  network_id = yandex_vpc_network.task6_network.id
  allocation_policy {
    location {
      zone_id = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.task6_subnet.id
    }
  }
  listener {
    name = "task6-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.task6_http_router.id
      }
    }
  }
}