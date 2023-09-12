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