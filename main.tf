locals {
  ceph_hosts = ["ceph-01","ceph-02","ceph-03"]
  rgw_hosts  = ["rgw-01","rgw-02"]

  # Public network IPs
  host_ip_map_public = merge(
    { for idx, h in local.ceph_hosts : h => cidrhost(var.network_cidr, var.ip_start_offset + idx) },
    { for idx, h in local.rgw_hosts  : h => cidrhost(var.network_cidr, var.ip_start_offset + length(local.ceph_hosts) + idx) }
  )
  public_prefix = tonumber(split("/", var.network_cidr)[1])

  # Cluster network IPs (optional)
  host_ip_map_cluster = var.enable_cluster_network ? merge(
    { for idx, h in local.ceph_hosts : h => cidrhost(var.cluster_network_cidr, var.cluster_ip_start_offset + idx) },
    { for idx, h in local.rgw_hosts  : h => cidrhost(var.cluster_network_cidr, var.cluster_ip_start_offset + length(local.ceph_hosts) + idx) }
  ) : {}
  cluster_prefix = tonumber(split("/", var.cluster_network_cidr)[1])
}

resource "tls_private_key" "cluster_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "proxmox_vm_qemu" "vms" {
  for_each     = local.host_ip_map_public
  name         = each.key
  target_node  = var.pm_target_node
  clone        = var.base_template
  full_clone   = true
  cores        = var.vm_vcpus
  sockets      = 1
  memory       = var.vm_memory_mb
  onboot       = true
  scsihw       = "virtio-scsi-pci"

  # Networking (public)
  network {
    model  = "virtio"
    bridge = var.pm_bridge
  }
  # Networking (cluster, optional)
  dynamic "network" {
    for_each = var.enable_cluster_network ? [1] : []
    content {
      model  = "virtio"
      bridge = var.cluster_bridge
    }
  }

  # Cloud-init
  ciuser     = "root"
  sshkeys    = tls_private_key.cluster_key.public_key_openssh
  nameserver = var.dns_server
  ipconfig0  = "ip=${each.value}/${local.public_prefix},gw=${var.gateway_ip}"
  ipconfig1  = var.enable_cluster_network && contains(keys(local.host_ip_map_cluster), each.key) ? "ip=${local.host_ip_map_cluster[each.key]}/${local.cluster_prefix}" : null

  # Extra OSD disks on ceph nodes
  dynamic "disk" {
    for_each = contains(["ceph-01","ceph-02","ceph-03"], each.key) ? toset([for i in range(var.osd_data_disks_per_node) : i]) : []
    content {
      type    = "scsi"
      storage = var.pm_storage
      size    = "${var.osd_data_disk_size_gb}G"
    }
  }
}

# Wait for ceph-01
resource "null_resource" "wait_ceph01" {
  depends_on = [ for k, v in proxmox_vm_qemu.vms : v ]
  provisioner "remote-exec" {
    inline = ["cloud-init status --wait || true", "echo ready"]
    connection { type = "ssh"; user = "root"; host = local.host_ip_map_public["ceph-01"]; private_key = tls_private_key.cluster_key.private_key_pem }
  }
}

# Render bootstrap script
data "template_file" "bootstrap" {
  template = file("${path.module}/templates/bootstrap.sh.tftpl")
  vars = {
    mon_ip        = local.host_ip_map_public["ceph-01"]
    ceph_release  = var.ceph_release
    rgw_port      = var.rgw_port
    realm         = "ceph-realm"
    zonegroup     = "ceph-zonegroup"
    zone          = "ceph-zone"
    osd_hosts     = join(" ", local.ceph_hosts)
    osd_ips       = join(" ", [for h in local.ceph_hosts : local.host_ip_map_public[h]])
    rgw_hosts     = join(" ", local.rgw_hosts)
    rgw_ips       = join(" ", [for h in local.rgw_hosts : local.host_ip_map_public[h]])
    rhel_major    = var.rhel_major
    ceph_distribution = var.ceph_distribution
    container_registry   = var.container_registry
    container_image_repo = var.container_image_repo
    container_image_tag  = var.container_image_tag
    registry_username    = coalesce(var.registry_username, "")
    registry_password    = coalesce(var.registry_password, "")
    enable_rgw_vip       = var.enable_rgw_vip ? "true" : "false"
    rgw_vip_ip           = var.rgw_vip_ip
    keepalived_vrid      = var.keepalived_vrid
    enable_cluster_network = var.enable_cluster_network ? "true" : "false"
    public_network_cidr    = var.network_cidr
    cluster_network_cidr   = var.cluster_network_cidr
    enable_dashboard_monitoring = var.enable_dashboard_monitoring ? "true" : "false"
    dashboard_admin_user       = var.dashboard_admin_user
    dashboard_admin_password   = var.dashboard_admin_password
  }
}

resource "null_resource" "bootstrap" {
  depends_on = [null_resource.wait_ceph01]
  provisioner "file" {
    content     = data.template_file.bootstrap.rendered
    destination = "/root/bootstrap.sh"
    connection { type = "ssh"; user = "root"; host = local.host_ip_map_public["ceph-01"]; private_key = tls_private_key.cluster_key.private_key_pem }
  }
  provisioner "remote-exec" {
    inline = ["chmod +x /root/bootstrap.sh", "/root/bootstrap.sh"]
    connection { type = "ssh"; user = "root"; host = local.host_ip_map_public["ceph-01"]; private_key = tls_private_key.cluster_key.private_key_pem }
  }
}
