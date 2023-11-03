variable "location" {
  type        = string
  description = "Azure Region name"
  default     = "westeurope"
}
variable "rg" {
  type        = string
  description = "resource group name"
  default = "rg-thom"
}

variable "vnet" {
  type        = string
  description = "vnet name"
  default = "vnet-thom"
}
variable "subnet" {
  type        = string
  description = "subnet name"
  default = "subnet-thom"
}

variable "publicip" {
  type        = string
  description = "name of public IP"
  default = "thom-pip"
}

variable "networkinterface" {
  type        = string
  description = "name of network interface"
  default = "thom-nic"
}

variable "nsg" {
  type = string
  description = "name of nsg"
  default = "thom-nsg"
}

variable "virtualmachine" {
    type = string
    description = "name of virtual machine"
    default = "thom-machine"
  
}

variable "vmsize" {
    type = string
    description = "size of virtual machine"
    default = "Standard_Ds1_v2"  
}

variable "adminusername" {
  type = string
  description = "admin username"
  default = "adminuser"
}

variable "osdisktype" {
  type = string
  description = "type of storage account"
  default = "Premium_LRS"
}