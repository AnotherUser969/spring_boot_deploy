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
  service_account_key_file = "${var.service_account_key_file}"
  folder_id                = "${var.folder_id}"
}

resource "yandex_compute_instance" "app_servers" {
  count = "${var.cluster_size_app}"
  name  = "server-${count.index}"
  platform_id = "standard-v3"


  resources {
    cores  = "${var.instance_cores_app}"
    memory = "${var.instance_memory_app}"
    core_fraction = "${var.instance_core_fraction_app}"
  }

  boot_disk {
    initialize_params {
	  type = "network-hdd"
	  size = "${var.instance_dist_size_app}"
      image_id = "fd830gae25ve4glajdsj"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    #nat       = true
  }

  metadata = {
    ssh-keys = "${file("${var.public_key_path}")}"
    user-data = "${file("${var.user_data_path}")}"
  }
}

resource "yandex_compute_instance" "monitoring" {
  count = "${var.cluster_size_mon}"
  name  = "monitoring-${count.index}"
  platform_id = "standard-v3"

  resources {
    cores  = "${var.instance_cores_mon}"
    memory = "${var.instance_memory_mon}"
    core_fraction = "${var.instance_core_fraction_mon}"
  }

  boot_disk {
    initialize_params {
	  type = "network-hdd"
	  size = "${var.instance_dist_size_mon}"
      image_id = "fd830gae25ve4glajdsj"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "${file("${var.public_key_path}")}"
    user-data = "${file("${var.user_data_path}")}"
  }
}

resource "yandex_compute_instance" "load_balancer" {
  count = "${var.cluster_size_lb}"
  name  = "load-balancer-${count.index}"
  platform_id = "standard-v3"

  resources {
    cores  = "${var.instance_cores_lb}"
    memory = "${var.instance_memory_lb}"
    core_fraction = "${var.instance_core_fraction_lb}"
  }

  boot_disk {
    initialize_params {
	  type = "network-hdd"
	  size = "${var.instance_dist_size_lb}"
      image_id = "fd830gae25ve4glajdsj"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "${file("${var.public_key_path}")}"
    user-data = "${file("${var.user_data_path}")}"
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
}
