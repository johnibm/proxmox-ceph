# Terraform (Proxmox) — Ceph 3×OSD + 2×RGW, RHEL, optional VIP & Dashboard

This deploys 5 VMs on **Proxmox** from a **cloud‑init RHEL (8/9) template**, bootstraps **Ceph (cephadm)** with 3 OSD nodes and 2 RGW nodes, supports **Upstream or IBM Storage Ceph** via container image registry selection, an **optional cluster network**, and **optional HAProxy+Keepalived VIP** in front of RGW. Dashboard & monitoring can be enabled.

> Lab/POC settings; review before production use.

## Quick start

1) Create `lab.auto.tfvars` (see example in the chat response) with your Proxmox API, template, storage, network, and image settings.
2) `terraform init && terraform apply -auto-approve`
3) Outputs show node IPs, endpoints, and the generated SSH private key (sensitive output).

## Notes
- Requires an existing **cloud‑init RHEL 8/9 template** named in `base_template`.
- Set `ceph_distribution` + `container_*` to switch between upstream and IBM images.
- `enable_cluster_network=true` adds a second NIC and passes `--cluster-network` to cephadm.
- Set `enable_dashboard_monitoring=true` to deploy the Ceph dashboard & monitoring stack.
