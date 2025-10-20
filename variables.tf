# Proxmox connection
variable "pm_api_url"       { type = string }
variable "pm_user"          { type = string }
variable "pm_password"      { type = string, default = null, sensitive = true }
variable "pm_token_id"      { type = string, default = null }
variable "pm_token_secret"  { type = string, default = null, sensitive = true }
variable "pm_tls_insecure"  { type = bool,   default = true }

# Placement
variable "pm_target_node" { type = string }
variable "pm_storage"     { type = string }
variable "pm_bridge"      { type = string, default = "vmbr0" }

# Template
variable "base_template"  { type = string, description = "Existing cloud-init RHEL template" }

# Sizing
variable "vm_memory_mb" { type = number, default = 8192 }
variable "vm_vcpus"     { type = number, default = 4 }

# Disks
variable "osd_data_disks_per_node" { type = number, default = 2 }
variable "osd_data_disk_size_gb"   { type = number, default = 50 }

# Network (public)
variable "network_cidr"    { type = string, default = "192.168.122.0/24" }
variable "ip_start_offset" { type = number, default = 101 }
variable "gateway_ip"      { type = string, default = "192.168.122.1" }
variable "dns_server"      { type = string, default = "1.1.1.1" }

# Ceph
variable "ceph_release" { type = string, default = "reef" }
variable "rgw_port"     { type = number, default = 8080 }

# OS
variable "rhel_major" { type = number, default = 9 }

# Container image source
variable "ceph_distribution"    { type = string, default = "upstream" }
variable "container_registry"   { type = string, default = "quay.io" }
variable "container_image_repo" { type = string, default = "ceph/ceph" }
variable "container_image_tag"  { type = string, default = "reef" }
variable "registry_username"    { type = string, default = null }
variable "registry_password"    { type = string, default = null, sensitive = true }

# Optional VIP
variable "enable_rgw_vip"  { type = bool,   default = false }
variable "rgw_vip_ip"      { type = string, default = "192.168.122.110" }
variable "keepalived_vrid"{ type = number, default = 51 }

# Cluster (backend) network
variable "enable_cluster_network"  { type = bool,   default = true }
variable "cluster_network_cidr"    { type = string, default = "192.168.123.0/24" }
variable "cluster_ip_start_offset" { type = number, default = 201 }
variable "cluster_bridge"          { type = string, default = "vmbr0" }

# Dashboard & monitoring
variable "enable_dashboard_monitoring" { type = bool,   default = true }
variable "dashboard_admin_user"        { type = string, default = "admin" }
variable "dashboard_admin_password"    { type = string, default = "ChangeMe!123", sensitive = true }
