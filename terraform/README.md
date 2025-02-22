# Proxmox Terraform Configuration

## Overview
This Terraform configuration automates the deployment of Ubuntu virtual machines on a Proxmox hypervisor. It provides a streamlined way to spin up multiple VMs with predefined configurations using cloud-init.

## Features
- Deploys multiple Ubuntu VMs on Proxmox
- Uses cloud-init for initial setup
- Configurable VM specs (CPU, RAM, Disk size, Network)
- Outputs assigned IP addresses

## Prerequisites
- A running Proxmox instance
- Terraform installed (>=1.2.0)
- Proxmox API credentials
- A pre-configured Ubuntu template in Proxmox

## Setup Instructions

### 1. Configure Terraform Variables
Create a `terraform.tfvars` file with your Proxmox credentials and settings:

```sh
proxmox_api_url  = "https://your-proxmox-url:8006/api2/json"
proxmox_user     = "root@pam"
proxmox_password = "your-password"
vm_name          = "homelab-vm"
vm_memory        = 4096
vm_cores         = 2
vm_disk_size     = "20G"
vm_network       = "vmbr0"
```

### 2. Initialize and Apply
```sh
terraform init
terraform plan
terraform apply -auto-approve
```

### 3. View Results
After deployment, get the assigned IP addresses:
```sh
echo "VM IPs: $(terraform output vm_ips)"
```

## Template Creation Guide
### Creating an Ubuntu-Server Template with Cloud-Init

1. Download Ubuntu cloud image:
```sh
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
```

2. Create and configure VM template:
```sh
qm create 9000 --name "ubuntu-template" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk 9000 jammy-server-cloudimg-amd64.img local-lvm
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --serial0 socket --vga serial0
```

3. Configure cloud-init:
```sh
qm set 9000 --ipconfig0 ip=dhcp
qm set 9000 --sshkeys ~/.ssh/id_rsa.pub  # Your SSH key for access
```

4. Convert to template:
```sh
qm template 9000
```

## SSH Key Setup
Generate a new SSH keypair if needed:
```sh
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

View your public key for terraform.tfvars:
```sh
cat ~/.ssh/id_rsa.pub
```

## Cleanup
To destroy the created VMs:
```sh
terraform destroy -auto-approve
``` 