resource "yandex_vpc_security_group" "task6_db_security_group" {
  name        = "task6-db-security-group"
  description = "PostgreSQL access only from webservers"
  network_id  = yandex_vpc_network.task6_network.id
  folder_id   = var.folder_id
  labels = {
    environment = "production"
  }

  ingress {
    description       = "PostgreSQL from VM security group"
    protocol          = "TCP"
    from_port         = 6432
    to_port           = 6432
    security_group_id = yandex_vpc_security_group.task6_vm_security_group.id
  }

  egress {
    description    = "Allow all outgoing traffic"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_mdb_postgresql_cluster" "task6_postgresql" {
  name        = "task6-postgresql"
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.task6_network.id
  folder_id   = var.folder_id
  security_group_ids = [yandex_vpc_security_group.task6_db_security_group.id]

  config {
    version = 15
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = 10
    }
  }

  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.task6_subnet.id
  }
}

resource "yandex_mdb_postgresql_user" "redmine_user" {
  cluster_id = yandex_mdb_postgresql_cluster.task6_postgresql.id
  name       = "redmine"
  password   = var.redmine_db_password
}

resource "yandex_mdb_postgresql_database" "redmine_db" {
  cluster_id = yandex_mdb_postgresql_cluster.task6_postgresql.id
  name       = "redmine"
  owner      = yandex_mdb_postgresql_user.redmine_user.name
}
