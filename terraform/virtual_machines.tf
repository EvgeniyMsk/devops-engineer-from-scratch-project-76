resource "yandex_compute_instance" "task6_vm1" {
  name        = "task6-vm1"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80293ig2816a78q276" # Ubuntu 24.04
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.task6_subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.task6_vm_security_group.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_public_key}"
  } 
}