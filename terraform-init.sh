#!/bin/bash

# system update
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl

# add GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

# add to repository
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# update repository and install Terraform
sudo apt-get update && sudo apt-get install terraform -y