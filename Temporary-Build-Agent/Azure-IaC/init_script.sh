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

# Install 
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash