output "vm_ips" {
  value = proxmox_vm_qemu.k3s_control[*].default_ipv4_address
}
