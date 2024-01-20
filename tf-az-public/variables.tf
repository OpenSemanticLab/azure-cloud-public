# variables.tf

# Resource Group Name
variable "rg_name" {
  type    = string
  default = "tf-az-osw"
}

# Resource Group Location
variable "rg_location" {
  type    = string
  default = "Germany West Central"
}

# Enviorenment Tag
variable "env_tag" {
  type    = string
  default = "tf-azure-osw"
}

# Public IP allocation method
variable "pubip_allocation_method" {
  type    = string
  default = "Static"
}

# Virtual Machines Unique Mapppings
variable "vm_map" {
  type = map(object({
    name      = string
    size      = string
    user      = string
    pubkey    = string
    publisher = string
    offer     = string
    sku       = string
    version   = string
    ip        = string
  }))
  default = {
    "vm-cpu-1" = {
      name      = "vm-osw-1"
      size      = "Standard_D4ds_v5"
      user      = "ubuntu"
      pubkey    = "ssh-rsa ..."
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
      version   = "latest"
      ip        = ""
    }
  }
}