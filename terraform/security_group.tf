resource "yandex_vpc_security_group" "task6_alb_security_group" {
  name        = "task6-alb-security-group"
  description = "Task6 ALB security group for task6 project [Hexlet]"
  network_id  = yandex_vpc_network.task6_network.id
  folder_id   = var.folder_id
  labels = {
    environment = "production"
  }

  ingress {
    description    = "Allow HTTP traffic"
    from_port      = 80
    to_port        = 80
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow HTTPS traffic"
    from_port      = 443
    to_port        = 443
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow test port for load balancer"
    from_port      = 30080
    to_port        = 30080
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "Allow all outgoing traffic"
    from_port      = 0
    to_port        = 65535
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "task6_vm_security_group" {
  name        = "task6-vm-security-group"
  description = "Task6 VM security group for task6 project [Hexlet]"
  network_id  = yandex_vpc_network.task6_network.id
  folder_id   = var.folder_id
  labels = {
    environment = "production"
  }

  ingress {
    description    = "Allow SSH traffic from home and office"
    from_port      = 22
    to_port        = 22
    protocol       = "TCP"
    v4_cidr_blocks = [var.home_ip, var.office_ip]
  }

  ingress {
    description       = "Allow HTTP traffic from ALB"
    from_port         = 80
    to_port           = 80
    protocol          = "TCP"
    security_group_id = yandex_vpc_security_group.task6_alb_security_group.id
  }

  ingress {
    description    = "Allow HTTP traffic from public IPs"
    from_port      = 80
    to_port        = 80
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "Allow all outgoing traffic from VM"
    from_port      = 0
    to_port        = 65535
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
