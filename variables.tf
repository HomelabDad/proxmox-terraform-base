variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type      = string
  sensitive = true
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "vm_count" {
  type    = number
  default = 2
}

variable "vm_name" {
  type    = string
  default = "ubuntu-vm"
}

variable "vm_memory" {
  type    = number
  default = 2048
}

variable "vm_cores" {
  type    = number
  default = 2
}

variable "vm_disk_size" {
  type    = string
  default = "32G"
}

variable "vm_network" {
  type    = string
  default = "vmbr0"
}

variable "ssh_key" {
  description = "SSH public key string for VM access"
  type        = string
}

variable "vm_ip_base" {
  description = "Base IP address (first 3 octets, e.g., '192.168.1.')"
  type        = string
}

variable "vm_ip_start" {
  description = "Starting number for the last octet of IP addresses"
  type        = number
  default     = 1
}

variable "vm_gateway" {
  description = "Gateway IP address for the network"
  type        = string
}
