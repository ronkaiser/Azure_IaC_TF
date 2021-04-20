variable "location" {
  description = "Region to build into"
  default     = "westus2"
}


variable "resource_group_name" {
  type        = string
  description = "Resource group name"
  default     = "TFResourceGroup"
}

variable "public_vm_size" {
  type = string
  description = "Vm-Size Config"
  default     = "Standard_DS1_v2"
}

variable "vnet-cidr" {
  type = string
  description = "Vnet address space(CIDR)"
  default     = "10.0.0.0/16"
}



variable "subnet_name" {
  default = ["Subnet-1", "Private-Subnet-1"]
}

variable "subnet_prefix" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}




variable "prefix" {
  type    = string
  default = "my"
}

variable "tags" {
  type = map

  default = {
    Environment = "Terraform GS"
    Dept        = "Engineering"
  }
}

variable "sku" {
  default = {
    location  = "16.04-LTS"
    location  = "18.04-LTS"
  }
}

variable "admin_username" {
    type = string
    description = "Administrator user name for virtual machine"
}

variable "admin_password" {
    type = string
    description = "Password must meet Azure complexity requirements"
}