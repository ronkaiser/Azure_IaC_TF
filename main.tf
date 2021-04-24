# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "57f61366-b99f-4f48-8086-e8ad016e0a38"
  tenant_id       = "9a53eaff-13c8-4a09-8ad6-4fa94ed5d56f"
}

# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
    name                = "myTFVnet"
    address_space       = [var.vnet-cidr]
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
}



# Create 2 subnet :Public and Private
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name[count.index]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_prefix[count.index]]
  count                = 2
}

# Create public IP
resource "azurerm_public_ip" "publicip" {
  name                = "myTFPublicIP"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  
}



# Create network interface for vm1
resource "azurerm_network_interface" "nic" {
  name                          = "myNIC"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  
  ip_configuration {
    name                          = "myNICConfg"
    subnet_id                     = azurerm_subnet.subnet[0].id
    private_ip_address_allocation = "dynamic"
  }
}




# Create network interface for vm2
resource "azurerm_network_interface" "nic2" {
  name                          = "myNIC2"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  
  ip_configuration {
    name                          = "myNICConfg2"
    subnet_id                     = azurerm_subnet.subnet[0].id
    private_ip_address_allocation = "dynamic"
  }
}


# Create network interface for vm3
resource "azurerm_network_interface" "nic3" {
  name                          = "myNIC3"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
 
  ip_configuration {
    name                          = "myNICConfg3"
    subnet_id                     = azurerm_subnet.subnet[0].id
    private_ip_address_allocation = "dynamic"
  }
}







#Create Load Balancer
resource "azurerm_lb" "publicLB" {
  name                = "Public_LoadBalancer"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.publicip.id
  }
}

#Create backend address pool for the lb
resource "azurerm_lb_backend_address_pool" "backend_address_pool_public" {
  loadbalancer_id = azurerm_lb.publicLB.id
  name            = "BackEndAddressPool"
}


#Associate network interface1 to the lb backend address pool
resource "azurerm_network_interface_backend_address_pool_association" "nic_back_association" {
  network_interface_id    = azurerm_network_interface.nic.id
  ip_configuration_name   = azurerm_network_interface.nic.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_address_pool_public.id
}
#Associate network interface1 to the lb backend address pool
resource "azurerm_network_interface_backend_address_pool_association" "nic2_back_association" {
  network_interface_id    = azurerm_network_interface.nic2.id
  ip_configuration_name   = azurerm_network_interface.nic2.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_address_pool_public.id
}
#Associate network interface1 to the lb backend address pool
resource "azurerm_network_interface_backend_address_pool_association" "nic3_back_association" {
  network_interface_id    = azurerm_network_interface.nic3.id
  ip_configuration_name   = azurerm_network_interface.nic3.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_address_pool_public.id
}





#Create lb probe for port 8080
resource "azurerm_lb_probe" "lb_probe" {
    name = "tcpProbe"
    resource_group_name = azurerm_resource_group.rg.name
    loadbalancer_id     = azurerm_lb.publicLB.id
    protocol            = "HTTP"
    port                = 8080
    interval_in_seconds = 5
    number_of_probes    = 2
    request_path        = "/"
  
}


#Create lb probe for port 22
resource "azurerm_lb_probe" "lb_probe_ssh" {
    name = "tcpProbeSsh"
    resource_group_name = azurerm_resource_group.rg.name
    loadbalancer_id     = azurerm_lb.publicLB.id
    protocol            = "Tcp"
    port                = 22
    interval_in_seconds = 5
    number_of_probes    = 2
  
}





#Create lb rule for port 8080
resource "azurerm_lb_rule" "LB_rule" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.publicLB.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = azurerm_lb.publicLB.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.lb_probe.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.backend_address_pool_public.id
}



#Create lb rule for port 22
resource "azurerm_lb_rule" "LB_rule2" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.publicLB.id
  name                           = "LBRuleSSH"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = azurerm_lb.publicLB.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.lb_probe_ssh.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.backend_address_pool_public.id
}


#Create lb rule for port 80
resource "azurerm_lb_rule" "LB_rule3" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.publicLB.id
  name                           = "LBRule3"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.publicLB.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.lb_probe_ssh.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.backend_address_pool_public.id
}




#Create public availability set
resource "azurerm_availability_set" "availability_set1" {
  name                = "public-aset"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

}



  
# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "myTFNSG"
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
    source_address_prefix      = "*"
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
    source_address_prefix      = "*"
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
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
   security_rule {
    name                       = "WEB"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  
   
	  }
}


#Associate subnet to subnet_network_security_group
resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.subnet[0].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}





#Associate network interface1 to subnet_network_security_group
resource "azurerm_network_interface_security_group_association" "nsg_nic" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


#Associate network interface2 to subnet_network_security_group
resource "azurerm_network_interface_security_group_association" "nsg_nic2" {
  network_interface_id      = azurerm_network_interface.nic2.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

#Associate network interface3 to subnet_network_security_group
resource "azurerm_network_interface_security_group_association" "nsg_nic3" {
  network_interface_id      = azurerm_network_interface.nic3.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}



# Create a Linux virtual machine 1
resource "azurerm_virtual_machine" "vm" {
  name                   = "myTFVM"
  location               = var.location
  resource_group_name    = azurerm_resource_group.rg.name
  availability_set_id    = azurerm_availability_set.availability_set1.id 
  network_interface_ids  = [azurerm_network_interface.nic.id]
  vm_size                = var.public_vm_size

  storage_os_disk {
    name              = "myOsDisk"
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
    computer_name  = "myTFVM"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}





# Create a Linux virtual machine 2
resource "azurerm_virtual_machine" "vm2" {
  name                   = "myTFVM2"
  location               = var.location
  resource_group_name    = azurerm_resource_group.rg.name
  network_interface_ids  = [azurerm_network_interface.nic2.id]
  vm_size                = var.public_vm_size
  availability_set_id    = azurerm_availability_set.availability_set1.id 

  storage_os_disk {
    name              = "myOsDisk2"
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
    computer_name  = "myTFVM2"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}




# Create a Linux virtual machine 3
resource "azurerm_virtual_machine" "vm3" {
  name                   = "myTFVM3"
  location               = var.location
  resource_group_name    = azurerm_resource_group.rg.name
  network_interface_ids  = [azurerm_network_interface.nic3.id]
  vm_size                = var.public_vm_size
  availability_set_id    = azurerm_availability_set.availability_set1.id 

  storage_os_disk {
    name              = "myOsDisk3"
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
    computer_name  = "myTFVM3"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

#Get data from vnet
data "azurerm_virtual_network" "data_vnet" {
  name                = azurerm_virtual_network.vnet.name
  resource_group_name = var.resource_group_name
}
#Get data from lb
data "azurerm_lb" "data_lb" {
  name                = azurerm_lb.publicLB.name
  resource_group_name = var.resource_group_name
}
#Get data from backend address pool
data "azurerm_lb_backend_address_pool" "data_pool" {
  name            = azurerm_lb_backend_address_pool.backend_address_pool_public.name
  loadbalancer_id = data.azurerm_lb.data_lb.id
}







#Get ip data
data "azurerm_public_ip" "ip" {
  name                = azurerm_public_ip.publicip.name
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_virtual_machine.vm]
  
}
#Print public ip
output "public_ip_address" {
  value = data.azurerm_public_ip.ip.ip_address
}

output "username" {
  value = var.admin_username
}

output "password" {
  value = var.admin_password
}