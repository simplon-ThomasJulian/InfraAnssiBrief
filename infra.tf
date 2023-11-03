terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.75.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

resource "azurerm_resource_group" "rgthom" {
  name     = var.rg
  location = var.location
}

resource "azurerm_virtual_network" "vnetthom" {
  name                = var.vnet
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rgthom.location
  resource_group_name = azurerm_resource_group.rgthom.name
}

resource "azurerm_subnet" "subnetthom" {
  name                 = var.subnet
  resource_group_name  = azurerm_resource_group.rgthom.name
  virtual_network_name = azurerm_virtual_network.vnetthom.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "thompip" {
  name                    = var.publicip
  location                = azurerm_resource_group.rgthom.location
  resource_group_name     = azurerm_resource_group.rgthom.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30
}

resource "azurerm_network_interface" "thomnic" {
  name                = var.networkinterface
  location            = azurerm_resource_group.rgthom.location
  resource_group_name = azurerm_resource_group.rgthom.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnetthom.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.thompip.id
  }
}

resource "azurerm_network_security_group" "thomnsg" {
  name                = var.nsg
  location            = azurerm_resource_group.rgthom.location
  resource_group_name = azurerm_resource_group.rgthom.name
}

# Règle autorisant le trafic entrant sur le port 22 (SSH)
resource "azurerm_network_security_rule" "ssh" {
  name                        = "ssh-rule"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rgthom.name
  network_security_group_name = azurerm_network_security_group.thomnsg.name
}

# Règle autorisant le trafic entrant sur le port 80 (HTTP)
resource "azurerm_network_security_rule" "http" {
  name                        = "http-rule"
  priority                    = 1002
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rgthom.name
  network_security_group_name = azurerm_network_security_group.thomnsg.name
}

# Règle autorisant le trafic entrant sur le port 443 (HTTPS)
resource "azurerm_network_security_rule" "https" {
  name                        = "https-rule"
  priority                    = 1003
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rgthom.name
  network_security_group_name = azurerm_network_security_group.thomnsg.name
}



resource "azurerm_linux_virtual_machine" "vmthom" {
  name                = var.virtualmachine
  resource_group_name = azurerm_resource_group.rgthom.name
  location            = azurerm_resource_group.rgthom.location
  size                = var.vmsize
  admin_username      = var.adminusername
  network_interface_ids = [
    azurerm_network_interface.thomnic.id,   
  ]

  admin_ssh_key {
    username   = var.adminusername
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.osdisktype
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "8-lvm-gen2"
    version   = "latest"
  }
  provisioner "local-exec" {
      command = <<-EOT
        ansible-galaxy install -r requirements.yml
        ansible-playbook playbook.yml -i azure_rm.yml
      EOT
    }
  }
