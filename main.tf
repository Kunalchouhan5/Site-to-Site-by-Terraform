# Resource Group - On-premises 
resource "azurerm_resource_group" "on-premises-rg" {
  name     = var.onprem-rg
  location = var.location
}

# Virtual Network - On-prem
resource "azurerm_virtual_network" "on-prem-vnet" {
  name                = "test-poc-on-prem-vnet-01"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.on-premises-rg.location
  resource_group_name = azurerm_resource_group.on-premises-rg.name
}

# Virtual Network Subnet
resource "azurerm_subnet" "onprem-workload-subnet" {
  name                 = "test-poc-onprem-wrkld-subnet-01"
  resource_group_name  = azurerm_resource_group.on-premises-rg.name
  virtual_network_name = azurerm_virtual_network.on-prem-vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Public IP - 1
resource "azurerm_public_ip" "on-prem-pip" {
  name                = "test-poc-onprem-pip-01"
  location            = azurerm_resource_group.on-premises-rg.location
  resource_group_name = azurerm_resource_group.on-premises-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Security Group
resource "azurerm_network_security_group" "onprem-nsg-1" {
  name                = "test-poc-onprem-comp-nsg-01"
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
  name                = "test-onp-vm"
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
resource "azurerm_resource_group" "hub-net-rg" {
  name     = "test-poc-hub-rg"
  location = "East US"
}

# Virtual Network - hub-Vnet
resource "azurerm_virtual_network" "hub-vnet" {
  name                = "test-poc-hub-vnet-01"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.hub-net-rg.location
  resource_group_name = azurerm_resource_group.sp-paas-rg.name
  depends_on = [ azurerm_resource_group.sp-paas-rg, azurerm_resource_group.on-premises-rg ]
}

# Virtual Network Subnet
resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.sp-paas-rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = ["10.1.0.0/26"]
}

# Virtual Network Subnet
resource "azurerm_subnet" "hub-workload-subnet" {
  name                 = "test-poc-hub-wrkld-subnet-01"
  resource_group_name  = azurerm_resource_group.hub-net-rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = ["10.1.0.64/26"]
}

# Hub - VNG_PublicIP
resource "azurerm_public_ip" "vng-pip" {
  name                = "test-poc-vng-pip-01"
  location            = azurerm_resource_group.hub-net-rg.location
  resource_group_name = azurerm_resource_group.hub-net-rg.name
  allocation_method   = "Static"
   sku                 = "Standard"
}

resource "azurerm_virtual_network_gateway" "VNG" {
  name                = "test-poc-vng"
  location            = azurerm_resource_group.hub-net-rg.location
  resource_group_name = azurerm_resource_group.hub-net-rg.name

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

# Public IP - Hub Network
resource "azurerm_public_ip" "hub-pip-01" {
  name                = "test-poc-hub-pip-01"
  location            = azurerm_resource_group.hub-net-rg.location
  resource_group_name = azurerm_resource_group.hub-net-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Security Group - Hub Network
resource "azurerm_network_security_group" "hub-nsg-1" {
  name                = "test-poc-hub-comp-nsg-01"
  location            = azurerm_resource_group.hub-net-rg.location
  resource_group_name = azurerm_resource_group.hub-net-rg.name
}

# Example NSG Rule (Allow SSH from any IP)
resource "azurerm_network_security_rule" "hub-rule-01" {
  name                        = "RDP-Allow"
  priority                    = 310
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.hub-net-rg.name
  network_security_group_name = azurerm_network_security_group.hub-nsg-1.name
}

# Network security group associate 
resource "azurerm_subnet_network_security_group_association" "hub-nsg-associate-1" {
  subnet_id                 = azurerm_subnet.hub-workload-subnet.id
  network_security_group_id = azurerm_network_security_group.hub-nsg-1.id
}


# Network Interface - Hub Network
resource "azurerm_network_interface" "hub-nic-1" {
  name                = "test-poc-hub-nic-1"
  location            = azurerm_resource_group.hub-net-rg.location
  resource_group_name = azurerm_resource_group.hub-net-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hub-workload-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.hub-pip-01.id
  }
}

# Windows Virtual Machine  -- Hub Network
resource "azurerm_windows_virtual_machine" "hub-vm" {
  name                = "test-hub-vm"
  resource_group_name = azurerm_resource_group.hub-comp-rg.name
  location            = azurerm_resource_group.hub-comp-rg.location
  size                = "Standard_D2s_v4"
  admin_username      = "kunal"
  admin_password      = "Admin@123456"
  network_interface_ids = [
    azurerm_network_interface.hub-nic-1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

# Local Network gateway - Hub Network
resource "azurerm_local_network_gateway" "LNG" {
  name                = "test-poc-hub-lng-01"
  resource_group_name = azurerm_resource_group.hub-net-rg.name
  location            = azurerm_resource_group.hub-net-rg.location
  gateway_address     = azurerm_public_ip.on-prem-pip.ip_address
  address_space       = ["10.0.0.0/24"]
}

resource "azurerm_virtual_network_gateway_connection" "onpremise" {
  name                = "connection"
  location            = azurerm_resource_group.hub-net-rg.location
  resource_group_name = azurerm_resource_group.hub-net-rg.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.VNG.id
  local_network_gateway_id   = azurerm_local_network_gateway.LNG.id

  shared_key = "12345"
}