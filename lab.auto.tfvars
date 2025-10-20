
# --- Proxmox API ---
pm_api_url   = "https://pve.example.com:8006/api2/json"
pm_user      = "terraform@pve"     # or "root@pam"
pm_token_id  = "terraform!tf-user" # recommended
pm_token_secret = "<redacted>"
pm_password  = null                # avoid if using token
pm_tls_insecure = true             # set false if your CA is trusted

# --- Placement ---
pm_target_node = "pve-node1"
pm_storage     = "local-lvm"
pm_bridge      = "vmbr0"

# --- Base template (cloud-init RHEL) ---
base_template  = "rhel9-ci-template" # must exist in Proxmox

# --- Sizing ---
vm_memory_mb = 8192
vm_vcpus     = 4

# --- OSD data disks on ceph-* nodes ---
osd_data_disks_per_node = 2
osd_data_disk_size_gb   = 50

# --- Network ---
network_cidr    = "192.168.122.0/24"
ip_start_offset = 101
gateway_ip      = "192.168.122.1"
dns_server      = "1.1.1.1"

# --- Ceph params ---
ceph_release = "reef"  # e.g., quincy, reef
rgw_port     = 8080

# --- Choose image source: upstream or IBM Storage Ceph ---
# upstream example:
ceph_distribution     = "upstream"        # or "ibm"
container_registry    = "quay.io"
container_image_repo  = "ceph/ceph"
container_image_tag   = "reef"            # match your ceph_release

# If your registry requires auth (e.g., IBM Entitled Registry), set:
registry_username     = null              # for IBM: "cp"
registry_password     = null              # for IBM: your entitlement key

# --- Optional: VIP in front of RGW via HAProxy+Keepalived ---
enable_rgw_vip  = true
rgw_vip_ip      = "192.168.122.110"       # free IP in the same subnet
keepalived_vrid = 51                      # VRRP ID (1..255), unique on your LAN

# IBM Ceph
#ceph_distribution     = "ibm"
#container_registry    = "cp.icr.io"
#container_image_repo  = "cp/ibm-ceph/ceph"
#container_image_tag   = "7.x.y"           # your IBM Ceph version tag
#registry_username     = "cp"
#registry_password     = "<your-ibm-entitlement-key>"
