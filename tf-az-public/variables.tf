# variables.tf

# Authors: 
#   Andreas Raeder, https://github.com/raederan 
#   Simon Stier, https://github.com/simontaurus

# Resource Group Name
variable "rg_name" {
  type    = string
  default = "tf-osw" # CHANGE THIS
}

# Resource Group Location
variable "rg_location" {
  type    = string
  default = "Germany West Central"
}

# Enviorenment Tag
variable "env_tag" {
  type    = string
  default = "tf-osw" # CHANGE THIS
}

# Public IP allocation method
variable "pubip_allocation_method" {
  type    = string
  default = "Static"
}

# Virtual Machines Unique Mapppings
variable "vm_map" {
  type = map(object({
    name         = string
    size         = string
    disk_size_gb = number
    user         = string
    pubkey       = string
    publisher    = string
    offer        = string
    sku          = string
    version      = string
    ip           = string
  }))
  default = {
    "vm-cpu-1" = {
      name         = "vm-osw-1"
      size         = "Standard_D4s_v5"  # no local storage
      disk_size_gb = 150                # directly attached to the VM
      user         = "ubuntu"
      pubkey       = ""                 # provide your public key or use default file
      publisher    = "Canonical"
      offer        = "0001-com-ubuntu-server-jammy"
      sku          = "22_04-lts-gen2"
      version      = "latest"
      ip           = ""                 # Resource ID of another public IP
    }
  }
}


