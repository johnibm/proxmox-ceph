terraform {
  required_version = ">= 1.5.0"
  required_providers {
    proxmox = { source = "telmate/proxmox", version = ">= 3.0.0" }
    tls     = { source = "hashicorp/tls",   version = ">= 4.0" }
    template= { source = "hashicorp/template", version = ">= 2.2.0" }
    null    = { source = "hashicorp/null", version = ">= 3.2.0" }
  }
}
