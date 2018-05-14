mkdir ~/.ssh
cp /mnt/c/Users/rcannon/OneDrive/Documents/Keep/.ssh/* ~/.ssh

curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/ubuntu/16.04/prod.list

sudo apt-get update

sudo apt-get install -y apt-transport-https unzip docker.io python3 python-pip nodejs zsh
sudo apt-get install -y --allow-unauthenticated powershell

pip install --upgrade pip

# Install kubectl
sudo snap install kubectl --classic

# Install Angular-cli
sudo npm install -g @angular/cli

# Install aws client
pip install awscli --upgrade --user

# Install samld

# Install terraform
wget https://releases.hashicorp.com/terraform/0.11.1/terraform_0.11.1_linux_amd64.zip
unzip terraform_0.11.1_linux_amd64.zip
rm terraform_0.11.1_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Copy profile from OneDrive
# Copy zsh config from OneDrive

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
