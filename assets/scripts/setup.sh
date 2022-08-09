#!/bin/bash
set -x

# Install necessary dependencies
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
sudo apt-get update
sudo apt-get -y -qq install curl wget git vim apt-transport-https ca-certificates
sudo add-apt-repository ppa:longsleep/golang-backports -y
sudo snap install go --classic 
sudo apt-get -q -y install postgresql-client-11
sudo bash 
apt install -y curl ca-certificates gnupg 
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/postgresql.list' 
apt update -y
apt install -y postgresql-client-11
pg_basebackup -V

yes | sudo apt-get install docker.io 


# add current user to docker group so there is no need to use sudo when running docker
sudo usermod -aG docker $(whoami)

sudo docker run --rm -p 5432:5432 -e POSTGRES_PASSWORD=mysecretpassword -d postgres:14



#TODO: make postgres start on startup
# []  create a systemd unit file for app - starts on boot instead of doing it manually 
# []  Do I have to create a systemD file on terraform ssh server: this would be all through instruqt sandbox environment? or Can I do it through here ? 
# [] It would make sense to do it through here right instead of using a systemD file bc from here it will already be baked into our packer image 


go --version 

# Setup sudo to allow no-password sudo for "hashicorp" group and adding "terraform" user
sudo groupadd -r hashicorp
sudo useradd -m -s /bin/bash terraform
sudo usermod -a -G hashicorp terraform
sudo cp /etc/sudoers /etc/sudoers.orig
echo "terraform  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/terraform

# Installing SSH key
sudo mkdir -p /home/terraform/.ssh
sudo chmod 700 /home/terraform/.ssh
sudo cp /tmp/tf-packer.pub /home/terraform/.ssh/authorized_keys
sudo chmod 600 /home/terraform/.ssh/authorized_keys
sudo chown -R terraform /home/terraform/.ssh
sudo usermod --shell /bin/bash terraform

# Create GOPATH for Terraform user & download the webapp from github


sudo -H -i -u terraform -- env bash << EOF
whoami
echo ~terraform

cd /home/terraform

export GOPATH=/home/terraform/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
export TMDB=af2b4e4b7c2c224650dfad4faa2de6ff
export POSTGRES_URL=postgres://postgres:mysecretpassword@localhost:5432/postgres
go install github.com/go-sql-driver/mysql
go install github.com/sabinlehaci/go-web-app@fce5140f2f3a609c36b6061b39726b0ee55ed6ca
go install github.com/sabinlehaci/go-web-app@master


EOF
