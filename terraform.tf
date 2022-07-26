terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.10"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://pcs02-fandango:8006/api2/json"
  pm_api_token_id = "terraform@pve!terraform-token"
  pm_api_token_secret = ""
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "kube-server" {
  count = 1
  name = "kube-server-0${count.index + 1}" 
  target_node = var.proxmox_host
  vmid = "40${count.index + 1}"
  clone = var.template_name
  agent = 1
  os_type = "cloud-init"
  cores = 4
  sockets = 1
  cpu = "host"
  memory = 4096
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"
  disk {
    slot = 0
    size = "10G"
    type = "scsi"
    storage = "fandango_expand01"
    iothread = 1
  }

  network {
    model = "virtio"
    bridge = "vmbr0"
    tag = "40"
  }
  
  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  ipconfig0 = "ip=192.168.4.1${count.index + 1}/24,gw=192.168.4.1"

  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}

resource "proxmox_vm_qemu" "kube-agent" {
  count = 3
  name = "kube-agent-0${count.index + 1}" 
  target_node = var.proxmox_host
  vmid = "41${count.index + 1}"
  clone = var.template_name
  agent = 1
  os_type = "cloud-init"
  cores = 4
  sockets = 1
  cpu = "host"
  memory = 16384
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"
  disk {
    slot = 0
    size = "10G"
    type = "scsi"
    storage = "fandango_expand02"
    iothread = 1
  }

  network {
    model = "virtio"
    bridge = "vmbr0"
    tag = "40"
  }
  
  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  ipconfig0 = "ip=192.168.4.2${count.index + 1}/24,gw=192.168.4.1"

  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}
