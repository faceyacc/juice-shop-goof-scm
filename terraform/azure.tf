# Terraform Azure Configuration with Vulnerabilities

provider "azurerm" {
  features {}
}

# Creating an Azure Storage Account with public access
resource "azurerm_storage_account" "vulnerable_storage_account" {
  name                     = "vulnstorageaccount"
  resource_group_name      = "example-resources"
  location                 = "West US"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  static_website {
    index_document = "index.html"
  }
}

# Creating a public IP address
resource "azurerm_public_ip" "vulnerable_public_ip" {
  name                = "vulnerable-public-ip"
  location            = "West US"
  resource_group_name = "example-resources"
  allocation_method   = "Dynamic"
}

# Creating a virtual machine with password authentication
resource "azurerm_virtual_machine" "vulnerable_vm" {
  name                  = "vulnerable-vm"
  location              = "West US"
  resource_group_name   = "example-resources"
  network_interface_ids = [azurerm_network_interface.vulnerable_nic.id]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "vulnerable_os_disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "adminuser"
    admin_password = "password1234!"  # Weak password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "Vulnerable"
  }
}

# Creating a network interface with public IP
resource "azurerm_network_interface" "vulnerable_nic" {
  name                = "vulnerable-nic"
  location            = "West US"
  resource_group_name = "example-resources"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vulnerable_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vulnerable_public_ip.id
  }
}

# Creating a subnet
resource "azurerm_subnet" "vulnerable_subnet" {
  name                 = "vulnerable-subnet"
  resource_group_name  = "example-resources"
  virtual_network_name = azurerm_virtual_network.vulnerable_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Creating a virtual network
resource "azurerm_virtual_network" "vulnerable_vnet" {
  name                = "vulnerable-vnet"
  location            = "West US"
  resource_group_name = "example-resources"
  address_space       = ["10.0.0.0/16"]
}
