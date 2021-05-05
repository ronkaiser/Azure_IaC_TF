# Create public IP for Jenkins Master
resource "azurerm_public_ip" "jpublicip" {
  name                = "JTFPublicIP"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"

}

# Create network interface for Jenkins Servers
resource "azurerm_network_interface" "jnic" {
  name                          = "JNIC"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "JNICConfg"
    subnet_id                     = azurerm_subnet.subnet[0].id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.jpublicip.id
  }
}

resource "azurerm_network_interface" "jsnic" {
  name                          = "JSNIC"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "JSNICConfg"
    subnet_id                     = azurerm_subnet.subnet[0].id
    private_ip_address_allocation = "dynamic"
  }
}

# Create Network Security Group and rule for Jenkins
resource "azurerm_network_security_group" "jnsg" {
  name                = "JTFNSG"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name


  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "62.90.143.129"
    destination_address_prefix = "*"
  }
   security_rule {
    name                       = "Port_8080"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "62.90.143.129"
    destination_address_prefix = "*"
  }
   security_rule {
    name                       = "Port-8080"
    priority                   = 360
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "62.90.143.129"
    destination_address_prefix = "*"
  }
}

# Create Network Security Group and rule for Jenkins slave
resource "azurerm_network_security_group" "jsnsg" {
  name                = "JSTFNSG"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name


  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
}

#Associate Jenkins network interface to subnet_network_security_group
resource "azurerm_network_interface_security_group_association" "jnsg" {
  network_interface_id      = azurerm_network_interface.jnic.id
  network_security_group_id = azurerm_network_security_group.jnsg.id
}

#Associate Jenkins slave network interface to subnet_network_security_group
resource "azurerm_network_interface_security_group_association" "jsnsg" {
  network_interface_id      = azurerm_network_interface.jsnic.id
  network_security_group_id = azurerm_network_security_group.jsnsg.id
}

# Create a Jenkins master
resource "azurerm_virtual_machine" "jenkins" {
  name                   = "Jenkins"
  location               = var.location
  resource_group_name    = azurerm_resource_group.rg.name
  #availability_set_id    = azurerm_availability_set.availability_set1.id
  network_interface_ids  = [azurerm_network_interface.jnic.id]
  vm_size                = var.public_vm_size

  storage_os_disk {
    name              = "JenkinsOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"

  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "JenkinsTFVM"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

# Create a Jenkins slave
resource "azurerm_virtual_machine" "slave" {
  name                   = "Slave"
  location               = var.location
  resource_group_name    = azurerm_resource_group.rg.name
  #availability_set_id    = azurerm_availability_set.availability_set1.id
  network_interface_ids  = [azurerm_network_interface.jsnic.id]
  vm_size                = var.public_vm_size

  storage_os_disk {
    name              = "SlaveOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"

  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "SlaveTFVM"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
