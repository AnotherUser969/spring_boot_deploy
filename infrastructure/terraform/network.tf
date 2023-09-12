resource "yandex_vpc_subnet" "subnet" {
  name           = "auto-subnet"
  zone           = "ru-central1-b"
  network_id     = "${var.network_id}"
  v4_cidr_blocks = ["192.168.${var.cird_net_block}.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  name       = "route-table"
  network_id = "${var.network_id}"

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

locals {
   prod_subnet_ids = yandex_vpc_subnet.prod_subnet.*.id
}