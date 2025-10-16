variable "tenant_id" {
  type = string
  default = "" #required tenant id
}

variable "subscription" {
  type = string
  default = "" #required subscription id 
}

variable "on_prem_rg" {
  type = string
  default = "test-poc-on-premises-Rg"
  description = "The name of the resource group"
}

variable "location" {
  type = string
  default = "Central India"
  description = "Location of on prem rg"
}

variable "on-prem-vnet-name" {
  type = string
  default = "test-poc-on-prem-vnet-01"
  description = "Name of Vnet"
}

variable "on-prem-address_space-1" {
  type = set(string)
  default = ["10.0.0.0/16"]
  description = "address space of virtual network"
}

variable "on-prem-subnet-name" {
  type = string
  default = "test-poc-onprem-wrkld-subnet-01"
  description = "name of subnet"
}

variable "on-prem-address_prefixes-1" {
  type = list(string)
  default = [ "10.0.0.0/24" ]
  description = "Value of address prefixes"
}

variable "on-prem-public-ip" {
  type = string
  default = "test-poc-onprem-pip-01"
  description = "on-prem-public-ip"
}

variable "on-prem-nsg" {
  type = string
  default = "test-poc-onprem-comp-nsg-01"
  description = "Name of the on-prem nsg"
}

variable "on-prem-nic" {
  type = string
  default = "test-poc-onprem-nic-1"
}

variable "on-prem-hyper-v" {
  type = string
  default = "test-onprem-vm"
}

variable "hub_rg" {
  type = string
  default = "test-poc-hub-rg"
  description = "The name of the resource group"
}

variable "hub-vnet-name" {
  type = string
  default = "test-poc-hub-vnet-01"
  description = "Name of Vnet"
}

variable "hub_address_space" {
  type = set(string)
  default = ["10.1.0.0/16"]
  description = "address space of virtual network"
}

variable "hub-subnet-name-1" {
  type = string
  default = "GatewaySubnet"
  description = "name of subnet"
}

variable "hub_address_prefixes-1" {
  type = list(string)
  default = [ "10.1.0.0/26" ]
  description = "Value of address prefixes"
}

variable "hub-subnet-name-2" {
  type = string
  default = "test-poc-hub-wrkld-subnet-01"
  description = "name of subnet"
}

variable "hub_address_prefixes-2" {
  type = list(string)
  default = [ "10.1.0.64/26" ]
  description = "Value of address prefixes"
}

variable "vng-public-ip" {
  type = string
  default = "test-poc-vng-pip-01"
  description = "VNG public ip"
}

variable "VNG-name" {
  type = string
  default = "test-poc-vng"
  description = "Name of the VNG"
}

variable "local-gateway-name" {
  type = string
  default = "test-poc-hub-lng-01"
  description = "name of the lng"
}

variable "connection_name" {
  type = string
  default = "connection"
  description = "name of the connection"
}


