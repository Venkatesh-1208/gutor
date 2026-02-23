##############################################################
# modules/spoke/main.tf
# Resources: Resource Group, Spoke VNet, Subnet, NSG,
#            N Linux VMs with NICs, Route Table
##############################################################

resource "azurerm_resource_group" "spoke" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

##############################################################
# Spoke VNet
##############################################################
resource "azurerm_virtual_network" "spoke" {
  name                = var.vnet_name
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

##############################################################
# Workload Subnet
##############################################################
resource "azurerm_subnet" "workload" {
  name                 = "snet-workload-${var.spoke_name}"
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.subnet_cidr]
}

##############################################################
# Network Security Group
##############################################################
resource "azurerm_network_security_group" "spoke" {
  name                = "nsg-${var.spoke_name}"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  tags                = var.tags

  # Allow inbound from Hub VNet (management/firewall)
  security_rule {
    name                       = "AllowFromHub"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  # Allow SSH from management subnet via Bastion
  security_rule {
    name                       = "AllowSSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  # Allow HTTP for internal workloads
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  # Deny all other inbound
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "workload" {
  subnet_id                 = azurerm_subnet.workload.id
  network_security_group_id = azurerm_network_security_group.spoke.id
}

##############################################################
# Route Table – send internet traffic via Hub Firewall
##############################################################
resource "azurerm_route_table" "spoke" {
  name                          = "rt-${var.spoke_name}"
  location                      = azurerm_resource_group.spoke.location
  resource_group_name           = azurerm_resource_group.spoke.name
  disable_bgp_route_propagation = true
  tags                          = var.tags

  route {
    name                   = "internet-via-hub-fw"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.hub_firewall_private_ip
  }
}

resource "azurerm_subnet_route_table_association" "workload" {
  subnet_id      = azurerm_subnet.workload.id
  route_table_id = azurerm_route_table.spoke.id
}

##############################################################
# Network Interfaces & Virtual Machines
##############################################################
resource "azurerm_network_interface" "vm" {
  count               = var.vm_count
  name                = "nic-${var.spoke_name}-vm${count.index}"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig-vm${count.index}"
    subnet_id                     = azurerm_subnet.workload.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.vm_count
  name                = "vm-${var.spoke_name}-${count.index}"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  size                = var.vm_size
  admin_username      = var.admin_username
  tags                = var.tags

  network_interface_ids = [azurerm_network_interface.vm[count.index].id]

  # Use SSH key or password authentication
  admin_password                  = var.admin_password
  disable_password_authentication = false

  os_disk {
    name                 = "osdisk-${var.spoke_name}-vm${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  boot_diagnostics {
    # Empty = uses managed storage account
  }
}

##############################################################
# Availability Set (optional – for zonal use azurerm_availability_zone)
##############################################################
resource "azurerm_availability_set" "spoke" {
  name                         = "avset-${var.spoke_name}"
  location                     = azurerm_resource_group.spoke.location
  resource_group_name          = azurerm_resource_group.spoke.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed                      = true
  tags                         = var.tags
}
