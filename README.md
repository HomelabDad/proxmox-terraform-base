# proxmox-terraform-base

## Overview
This project uses Terraform to automate the deployment of Ubuntu virtual machines on a Proxmox hypervisor. It allows you to quickly spin up multiple VMs with predefined configurations.

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

### 1. Clone the Repository
```sh
git clone https://github.com/HomelabDad/proxmox-terraform-base.git
cd proxmox-terraform-base
```

### 2. Configure Terraform Variables

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

### 3. Initialize Terraform

```sh
terraform init
```

### 4. 

```sh
terraform plan
terraform apply -auto-approve
```

### 5.

After deployment, Terraform will output the assigned IP addresses:

```sh
echo "VM IPs: $(terraform output vm_ips)"
```

### Customization 

You can modify variables.tf to set default values for your VMs. Adjust CPU, RAM, and storage settings to fit your needs.

### Cleanup

To destroy the created VMs:

```sh
terraform destroy -auto-approve
```

### Guide to create an Ubuntu-Server template with cloud-init for terrerform deployment

```sh
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
```
##### Convert the image to a proxmox-compatible format
```sh
qm create 9000 --name "ubuntu-template" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk 9000 jammy-server-cloudimg-amd64.img local-lvm
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --serial0 socket --vga serial0
```
##### Configure cloud-init

```sh
qm set 9000 --ipconfig0 ip=dhcp
qm set 9000 --sshkeys ~/.ssh/id_rsa.pub  # Your SSH key for access
```
#### convert VM to template

```sh
qm template 9000
```

#### Other Notes That are still relevant

Pull Ubuntu 22.04 ISO

`wget https://releases.ubuntu.com/jammy/ubuntu-22.04.5-live-server-amd64.iso`

Create keypair

`ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""`

Reference the key terraform.tfvars you can find you key by running `cat ~/.ssh/id_rsa.pub`


#### Author: Jared Wilson
