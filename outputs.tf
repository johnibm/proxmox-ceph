output "node_ips"      { value = local.host_ip_map_public }
output "rgw_endpoints" {
  value = [
    var.enable_rgw_vip ? "http://${var.rgw_vip_ip}:${var.rgw_port}" : "",
    "http://${local.host_ip_map_public[local.rgw_hosts[0]]}:${var.rgw_port}",
    "http://${local.host_ip_map_public[local.rgw_hosts[1]]}:${var.rgw_port}"
  ]
}
output "ssh_private_key_pem" { value = tls_private_key.cluster_key.private_key_pem, sensitive = true }
