#! /bin/bash

# These tools are needed based on this https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt

# Making sure curl installed
sudo apt update -y && sudo apt upgrade -y
sudo apt install curl -y

# Installing Packer - https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update -y && sudo apt-get install packer -y

# Install Git
sudo apt install git-all -y

# Install azure cli
# https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg

sudo mkdir -p /etc/apt/keyrings
curl -sLS https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
sudo chmod go+r /etc/apt/keyrings/microsoft.gpg

AZ_DIST=$(lsb_release -cs)
echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_DIST main" |
sudo tee /etc/apt/sources.list.d/azure-cli.list

sudo apt-get update -y 
sudo apt-get install azure-cli -y

