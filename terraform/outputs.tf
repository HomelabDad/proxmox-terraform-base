output "vm_ips" {
  value = proxmox_vm_qemu.ubuntu[*].default_ipv4_address
}
