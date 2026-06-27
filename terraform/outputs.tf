output "vm1_public_ip" {
  value = yandex_compute_instance.task6_vm1.network_interface.0.nat_ip_address
}

output "alb_public_ip" {
  value = yandex_alb_load_balancer.task6_load_balancer.listener.0.endpoint.0.address.0.external_ipv4_address.0.address
}