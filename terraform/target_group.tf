resource "yandex_alb_target_group" "task6_target_group" {
  name      = "task6-target-group"
  folder_id = var.folder_id

  target {
    subnet_id  = yandex_vpc_subnet.task6_subnet.id
    ip_address = yandex_compute_instance.task6_vm1.network_interface.0.ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.task6_subnet.id
    ip_address = yandex_compute_instance.task6_vm2.network_interface.0.ip_address
  }
}
