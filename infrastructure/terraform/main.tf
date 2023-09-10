terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
   backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "terraform-state-backet-nodes"
    region     = "ru-central1-b"
    key        = "terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  zone                     = "ru-central1-b"
  service_account_key_file = "/home/user/key.json"
  folder_id                = "b1g3a65ovr0uv7n30pq7"
}

resource "yandex_compute_instance" "app_servers" {
  count = 2
  name  = "server-${count.index}"
  platform_id = "standard-v3"


  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
	  type = "network-hdd"
	  size = 5
      image_id = "fd808e721rc1vt7jkd0o"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.prod_subnet.id
    #nat       = true
  }

  metadata = {
    ssh-keys = "${file("/home/user/cloud-ssh.pub")}"
    user-data = "${file("/home/user/metadata")}"
  }
}

resource "yandex_compute_instance" "monitoring" {
  count = 1
  name  = "monitoring"
  platform_id = "standard-v3"

  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
	  type = "network-hdd"
	  size = 5
      image_id = "fd808e721rc1vt7jkd0o"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.prod_subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "${file("/home/user/cloud-ssh.pub")}"
    user-data = "${file("/home/user/metadata")}"
  }
}

resource "yandex_compute_instance" "load_balancer" {
  count = 1
  name  = "load-balancer"
  platform_id = "standard-v3"

  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
	  type = "network-hdd"
	  size = 12
      image_id = "fd808e721rc1vt7jkd0o"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.prod_subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "${file("/home/user/cloud-ssh.pub")}"
    user-data = "${file("/home/user/metadata")}"
  }
}

resource "yandex_vpc_network" "prod_network" {
  name = "prod_network"
}

resource "yandex_vpc_subnet" "prod_subnet" {
  name           = "prod_subnet"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.prod_network.id
  v4_cidr_blocks = ["192.168.50.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  name       = "route-table"
  network_id = yandex_vpc_network.prod_network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

locals {
   app_servers_ips = {
	 internal = ["${yandex_compute_instance.app_servers.*.network_interface.0.ip_address}"]
	 external = ["${yandex_compute_instance.app_servers.*.network_interface.0.nat_ip_address}"]
   }
   load_balancer_ips = {
	 internal = ["${yandex_compute_instance.load_balancer.*.network_interface.0.ip_address}"]
	 external = ["${yandex_compute_instance.load_balancer.*.network_interface.0.nat_ip_address}"]
   }
   monitoring_ips = {
	 internal = ["${yandex_compute_instance.monitoring.*.network_interface.0.ip_address}"]
	 external = ["${yandex_compute_instance.monitoring.*.network_interface.0.nat_ip_address}"]
   }
   prod_subnet_ids = yandex_vpc_subnet.prod_subnet.*.id
}

output "app_servers_ips" {
  value = "${local.app_servers_ips}"
}
output "load_balancer_ips" {
  value = "${local.load_balancer_ips}"
}
output "monitoring_ips" {
  value = "${local.monitoring_ips}"
}
output "prod_subnet_ids" {
  value = "${local.prod_subnet_ids}"
}
#output "folder_id" {
#  value = "${var.folder_id}"
#}

#output "internal_ip_address_server" {
#  value = yandex_compute_instance.server.*.network_interface.0.ip_address
#}

#output "external_ip_address_server" {
#  value = yandex_compute_instance.server.*.network_interface.0.nat_ip_address
#}
