# main.tf

# Configure Azure provider source and version
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "tf-rg" {
  name     = var.rg_name
  location = var.rg_location
  tags = {
    environment = var.env_tag
  }
}

# Create a virtual network
resource "azurerm_virtual_network" "tf-vnet" {
  name                = "${var.rg_name}-vnet"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name
  address_space       = ["10.123.0.0/16"]
  tags = {
    environment = var.env_tag
  }
}

# Create a subnet
resource "azurerm_subnet" "tf-subnet" {
  name                 = "${var.rg_name}-subnet-1"
  resource_group_name  = azurerm_resource_group.tf-rg.name
  virtual_network_name = azurerm_virtual_network.tf-vnet.name
  address_prefixes     = ["10.123.1.0/24"]
}

# Create a security group
resource "azurerm_network_security_group" "tf-nsg" {
  name                = "${var.rg_name}-nsg"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name
  tags = {
    environment = var.env_tag
  }
}

# Create a security group rule
resource "azurerm_network_security_rule" "tf-dev-rule" {
  name                        = "${var.rg_name}-dev-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*" # public access
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tf-rg.name
  network_security_group_name = azurerm_network_security_group.tf-nsg.name
}

# Create a subnet network security group association
resource "azurerm_subnet_network_security_group_association" "tf-subnet-nsg" {
  subnet_id                 = azurerm_subnet.tf-subnet.id
  network_security_group_id = azurerm_network_security_group.tf-nsg.id
}

# Create a public ip
resource "azurerm_public_ip" "tf-pubip" {
  for_each = var.vm_map

  name                = "${each.value.name}-pubip"
  allocation_method   = var.pubip_allocation_method
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name

  tags = {
    environment = var.env_tag
  }
}

# Create a network interface
resource "azurerm_network_interface" "tf-nic" {
  for_each = var.vm_map

  name                = "${each.value.name}-nic"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name

  ip_configuration {
    name                          = "${each.value.name}-ipconfig"
    subnet_id                     = azurerm_subnet.tf-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = each.value.ip != "" ? each.value.ip : azurerm_public_ip.tf-pubip[each.key].id
  }

  tags = {
    environment = var.env_tag
  }
}

# Create a linux virtual machine
resource "azurerm_linux_virtual_machine" "tf-vm" {
  for_each = var.vm_map

  name                = each.value.name
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name

  size                  = each.value.size
  admin_username        = each.value.user
  network_interface_ids = [azurerm_network_interface.tf-nic[each.key].id]

  admin_ssh_key {
    username   = each.value.user
    # generate with "ssh-keygen"
    # public_key = file("~/.ssh/id_rsa.pub")
    public_key = each.value.pubkey
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = each.value.publisher
    offer     = each.value.offer
    sku       = each.value.sku
    version   = each.value.version
  }

  computer_name                   = each.value.name
  disable_password_authentication = true

  tags = {
    environment = var.env_tag
  }
}

# Create a local file as .txt containing the public ip of the vm
resource "local_file" "tf-vm-pubip" {
  for_each = var.vm_map

  content  = azurerm_linux_virtual_machine.tf-vm[each.key].public_ip_address
  filename = "${path.module}/inventory/${each.value.name}.txt"
}
