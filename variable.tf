variable "tenant_id" {
  type = string
  default = "6c96c136-8a5f-4c33-8ca1-48281b0aa8df"
}

variable "subscription" {
  type = string
  default = "ff796b21-0b11-4d2f-8d9a-23823e9d8709"
}

variable "on_prem_rg" {
  type = string
  default = "test-poc-on-premises-Rg"
  description = "The name of the resource group"
}

variable "location" {
  type = string
  default = "Central India"
  description = "LOcation of on prem rg"
}

variable "Vnet-name" {
  type = string
  default = "test-VNet"
  description = "Name of Vnet"
}

variable "address_space" {
  type = set(string)
  default = ["10.1.0.0/16"]
  description = "address space of virtual network"
}

variable "Subnet-name" {
  type = string
  default = "AzureFirewallSubnet"
  description = "name of subnet"
}

variable "address_prefixes" {
  type = list(string)
  default = [ "10.1.0.0/26" ]
  description = "Value of address prefixes"
}

variable "public-ip" {
  type = string
  default = "FW-pip"
  description = "Firewall public IP"
}