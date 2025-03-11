packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "test-ubuntu-template" {
  # Proxmox Connection Settings
  ssh_username = var.username
  # ssh_password = var.password
  ssh_password         = var.password_hash
  ssh_private_key_file = var.private_key
  proxmox_url          = var.proxmox_api_url
  username             = var.proxmox_api_token_id
  token                = var.proxmox_api_token_secret
  node                 = "proxmox" # You might want to adjust this to your node name
  # (optional) skip tls verification
  insecure_skip_tls_verify = true

  # VM General Settings
  vm_id                = "8000"
  vm_name              = "test-ubuntu-template"
  template_description = "Ubuntu 22.04 Cloud Image Template"

  # VM OS Settings
  boot_iso {
    iso_url          = "https://releases.ubuntu.com/jammy/ubuntu-22.04.5-live-server-amd64.iso"
    iso_checksum     = "9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"
    iso_storage_pool = "local"
    unmount          = true
  }

  # VM System Settings
  cores  = "2"
  memory = "2048"

  # VM Hard Disk Settings
  scsi_controller = "virtio-scsi-pci"

  disks {
    disk_size    = "20G"
    storage_pool = "local-lvm"
    type         = "scsi"
  }


  # VM Network Settings
  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = "false"
  }

  # VM Cloud-Init Settings
  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"

  # (Optional) Bind IP Address and Port
  http_bind_address = "0.0.0.0"
  http_port_min     = 8802
  http_port_max     = 8802
  # HTTP Settings for autoinstall
  # the httpy directory is used to store cloud-init configuration files suchs as user-data, meta-data, and network-config. 
  http_directory = "http"
  ssh_timeout    = "20m"

  # Boot and Console Settings
  # PACKER Boot Commands
  # What is going on with the nocloud-net -- Injects the Cloud-Init configuration using the NoCloud-Net datasource.
  # Uses Packer to boot a VM, modify the GRUB boot options, and tell it to pull its Cloud-Init user-data and meta-data from a local HTTP server.
  # The HTTP server is temporarily started by Packer to provide the required Cloud-Init configuration.
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]
  boot       = "c"
  boot_wait  = "10s"
  qemu_agent = true
}

build {
  sources = ["source.proxmox-iso.test-ubuntu-template"]

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
  # removes instance-specific data and cleans up the system. 
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 5; done",
      "echo 'Cloud-init finished'",
      # Add a small delay after cloud-init finishes
      "sleep 30",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt -y autoremove --purge",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo rm -f /etc/netplan/00-installer-config.yaml",
      "sudo sync"
    ]
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
  provisioner "file" {
    source      = "files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
  provisioner "shell" {
    inline = ["sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg"]
  }
}

# Variables
variable "proxmox_api_url" {
  type      = string
  sensitive = true
}

variable "proxmox_api_token_id" {
  type      = string
  sensitive = true
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "public_key" {
  type        = string
  description = "Your SSH public key content"
}

variable "username" {
  type    = string
  default = "ubuntu"
}

variable "password" {
  type      = string
  sensitive = true
}

# Generate password hash for cloud-init
variable "password_hash" {
  type      = string
  sensitive = true
  # You'll need to generate this using: mkpasswd --method=SHA-512 --rounds=4096
  # Or use the hash you generated elsewhere
}

variable "private_key" {
  type        = string
  sensitive   = true
  description = "SSH private key file path"
}