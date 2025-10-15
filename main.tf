# Resource Group - On-premises 
resource "azurerm_resource_group" "on-premises-rg" {
  name     = var.on_prem_rg
  location = var.location
}

# Virtual Network - On-prem
resource "azurerm_virtual_network" "on-prem-vnet" {
  name                = var.on-prem-vnet-name
  address_space       = var.on-prem-address_space-1
  location            = var.location
  resource_group_name = azurerm_resource_group.on-premises-rg.name
}

# Virtual Network Subnet
resource "azurerm_subnet" "onprem-workload-subnet" {
  name                 = var.on-prem-subnet-name
  resource_group_name  = azurerm_resource_group.on-premises-rg.name
  virtual_network_name = azurerm_virtual_network.on-prem-vnet.name
  address_prefixes     = var.on-prem-address_prefixes-1
}

# Public IP - 1
resource "azurerm_public_ip" "on-prem-pip" {
  name                = var.on-prem-public-ip 
  location            = var.location
  resource_group_name = azurerm_resource_group.on-premises-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Security Group
resource "azurerm_network_security_group" "onprem-nsg-1" {
  name                = var.on-prem-nsg
  location            = azurerm_resource_group.on-premises-rg.location
  resource_group_name = azurerm_resource_group.on-premises-rg.name
}

# Example NSG Rule (Allow SSH from any IP)
resource "azurerm_network_security_rule" "onprem-rule-1" {
  name                        = "RDP-Allow"
  priority                    = 310
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.on-premises-rg.name
  network_security_group_name = azurerm_network_security_group.onprem-nsg-1.name
}

# Network security group associate 
resource "azurerm_subnet_network_security_group_association" "onprem-nsg-associate-1" {
  subnet_id                 = azurerm_subnet.onprem-workload-subnet.id
  network_security_group_id = azurerm_network_security_group.onprem-nsg-1.id
}

# Network Interface - Onprem Network
resource "azurerm_network_interface" "onprem-nic-1" {
  name                = "test-poc-onprem-nic-1"
  location            = azurerm_resource_group.on-premises-rg.location
  resource_group_name = azurerm_resource_group.on-premises-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.onprem-workload-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.on-prem-pip.id
  }
}

# Windows Virtual Machine -- 1
resource "azurerm_windows_virtual_machine" "Hyper-v" {
  name                = var.on-prem-hyper-v
  resource_group_name = azurerm_resource_group.on-premises-rg.name
  location            = azurerm_resource_group.on-premises-rg.location
  size                = "Standard_D4s_v3"
  admin_username      = "kunal"
  admin_password      = "Admin@123456"
  network_interface_ids = [
    azurerm_network_interface.onprem-nic-1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}


# Resource Group - Hub-rg
resource "azurerm_resource_group" "hub-resource_rg" {
  name     = var.hub_rg
  location = var.location
}

# Virtual Network - hub-Vnet
resource "azurerm_virtual_network" "hub-vnet" {
  name                = var.hub-vnet-name
  address_space       = var.hub_address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.hub-resource_rg.name
  depends_on = [ azurerm_resource_group.hub-resource_rg, azurerm_resource_group.on-premises-rg ]
}

# Virtual Network Subnet
resource "azurerm_subnet" "gateway" {
  name                 = var.hub-subnet-name-1
  resource_group_name  = azurerm_resource_group.hub-resource_rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = var.hub_address_prefixes-1
}

# Virtual Network Subnet
resource "azurerm_subnet" "hub-workload-subnet" {
  name                 = var.hub-subnet-name-2
  resource_group_name  = azurerm_resource_group.hub-resource_rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = var.hub_address_prefixes-2
}

# Hub - VNG_PublicIP
resource "azurerm_public_ip" "vng-pip" {
  name                = var.vng-public-ip
  location            = var.location
  resource_group_name = azurerm_resource_group.hub-resource_rg.name
  allocation_method   = "Static"
   sku                 = "Standard"
}

resource "azurerm_virtual_network_gateway" "VNG" {
  name                = var.VNG-name
  location            = var.location
  resource_group_name = azurerm_resource_group.hub-resource_rg.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vng-pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway.id
  }
}

# Local Network gateway - Hub Network
resource "azurerm_local_network_gateway" "LNG" {
  name                = var.local-gateway-name
  resource_group_name = azurerm_resource_group.hub-resource_rg.name
  location            = var.location
  gateway_address     = azurerm_public_ip.on-prem-pip.ip_address
  address_space       = var.on-prem-address_prefixes-1
}

resource "azurerm_virtual_network_gateway_connection" "onpremise" {
  name                = var.connection_name
  location            = var.location
  resource_group_name = azurerm_resource_group.hub-resource_rg.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.VNG.id
  local_network_gateway_id   = azurerm_local_network_gateway.LNG.id

  shared_key = "12345"
}