#!/bin/bash
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y docker.io ca-certificates curl \
  apt-transport-https lsb-release gnupg wget unzip software-properties-common gnupg2
sudo systemctl enable --now docker
sudo usermod -aG docker azureuser
sudo curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash