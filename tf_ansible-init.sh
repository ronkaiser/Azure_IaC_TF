#!/bin/bash

# system update
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl

# add GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

# add to repository
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# update repository and install Terraform
sudo apt-get update && sudo apt-get install terraform -y

# ansible installation
sudo apt update
sudo apt install software-properties-common -y
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y