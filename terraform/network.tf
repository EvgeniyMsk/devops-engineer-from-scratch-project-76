resource "yandex_vpc_network" "task6_network" {
  name        = "task6_network-network"
  description = "Network for task6 project [Hexlet]"
  labels = {
    environment = "production"
  }
}

resource "yandex_vpc_subnet" "task6_subnet" {
  name           = "task6-subnet"
  v4_cidr_blocks = ["10.2.0.0/16"]
  description    = "Subnet for task6 project [Hexlet]"
  labels = {
    environment = "production"
  }
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.task6_network.id
  route_table_id = yandex_vpc_route_table.task6_nat_route_table.id
}

resource "yandex_vpc_gateway" "task6_nat_gateway" {
  name      = "nat-gateway"
  folder_id = var.folder_id
  labels = {
    environment = "production"
  }
  description = "NAT gateway for task6 project [Hexlet]"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "task6_nat_route_table" {
  name       = "nat-route-table"
  folder_id  = var.folder_id
  network_id = yandex_vpc_network.task6_network.id
  description = "Route table for task6 project [Hexlet]"
  labels = {
    environment = "production"
  }
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.task6_nat_gateway.id
  }
}