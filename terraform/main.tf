# K3s Control Node
resource "proxmox_vm_qemu" "k3s_control" {
  # VM name and basic configuration
  name        = "k3s-control"
  target_node = "proxmox"              # The Proxmox host to deploy on
  clone       = "k3s-control-template" # Template to clone from

  # Hardware specifications
  cores  = 4
  memory = 4096              # RAM in MB
  scsihw = "virtio-scsi-pci" # SCSI controller type

  # Primary disk configuration
  disk {
    slot    = "scsi0"
    size    = "40G"
    type    = "disk"
    storage = "local-lvm" # Storage pool in Proxmox
  }
  # Cloud-init disk for initialization
  disk {
    slot    = "ide2"
    size    = "4M"
    type    = "cloudinit"
    storage = "local-lvm"
  }

  # Network configuration
  network {
    id     = 0
    model  = "virtio" # Network adapter type
    bridge = "vmbr0"  # Bridge interface on Proxmox host
  }

  # Cloud-init configuration
  os_type   = "cloud-init"
  ipconfig0 = "ip=${var.control_node_ip}/24,gw=${var.vm_gateway}" # Static IP configuration
  sshkeys   = var.ssh_key                                         # SSH key for authentication

  ciuser       = "ubuntu"           # Default user
  nameserver   = "8.8.8.8"          # DNS server
  searchdomain = "vermillion.local" # Search domain for DNS

  automatic_reboot = true

  # Install K3s on the control node and wait for token file
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = var.control_node_ip
      private_key = file(var.private_key_path)
    }

    inline = [
      "curl -sfL https://get.k3s.io | sh -s - server",
      "sleep 10",                                                               # Give K3s time to initialize
      "sudo cp /var/lib/rancher/k3s/server/node-token /home/ubuntu/node-token", # Copy to a location we can access
      "sudo chown ubuntu:ubuntu /home/ubuntu/node-token"                        # Change ownership to ubuntu user
    ]
  }

  # Get the token file locally
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -i ${var.private_key_path} ubuntu@${var.control_node_ip}:/home/ubuntu/node-token node-token.txt"
  }

  # Prevent Terraform from modifying certain attributes after creation
  lifecycle {
    ignore_changes = [network, sshkeys]
  }
}

# K3s Worker Nodes
resource "proxmox_vm_qemu" "k3s_worker" {
  count       = var.worker_count                # Number of worker nodes to create
  name        = "k3s-worker-${count.index + 1}" # Numbered name for each worker
  target_node = "proxmox"
  clone       = "k3s-worker-template"

  # Hardware specifications (less resources than control node)
  cores  = 2
  memory = 2048
  scsihw = "virtio-scsi-pci"

  # Similar disk configuration as control node
  disk {
    slot    = "scsi0"
    size    = "40G"
    type    = "disk"
    storage = "local-lvm"
  }
  disk {
    slot    = "ide2"
    size    = "4M"
    type    = "cloudinit"
    storage = "local-lvm"
  }

  # Network configuration
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  # Cloud-init configuration with dynamic IP addressing
  os_type   = "cloud-init"
  ipconfig0 = "ip=${var.worker_ip_base}${count.index + var.worker_ip_start}/24,gw=${var.vm_gateway}"
  sshkeys   = var.ssh_key

  ciuser       = "ubuntu"
  nameserver   = "8.8.8.8"
  searchdomain = "vermillion.local"

  automatic_reboot = true

  # Copy the K3s token to the worker node
  provisioner "file" {
    source      = "node-token.txt"
    destination = "/tmp/node-token"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = "${var.worker_ip_base}${count.index + var.worker_ip_start}"
      private_key = file(var.private_key_path)
    }
  }

  # Join the worker to the K3s cluster
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = "${var.worker_ip_base}${count.index + var.worker_ip_start}"
      private_key = file(var.private_key_path)
    }

    inline = [
      "TOKEN=$(cat /tmp/node-token)",
      "curl -sfL https://get.k3s.io | K3S_URL=https://${var.control_node_ip}:6443 K3S_TOKEN=\"$TOKEN\" sh -",
      "rm /tmp/node-token" # Clean up the token file
    ]
  }

  # Ensure control node is created before workers
  depends_on = [proxmox_vm_qemu.k3s_control]

  # Prevent Terraform from modifying certain attributes after creation
  lifecycle {
    ignore_changes = [network, sshkeys]
  }
}