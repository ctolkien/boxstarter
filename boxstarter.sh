curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/ubuntu/16.04/prod.list

sudo apt-get update

sudo apt-get install -y apt-transport-https unzip docker.io python3 python-pip nodejs zsh
sudo apt-get install -y --allow-unauthenticated powershell

#sudo pip install --upgrade pip

# Install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# Install Angular-cli
sudo npm install -g @angular/cli

# Install aws client
pip install awscli --user

# Install samld
pip install samlkeygen --user

# Install terraform
wget https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip
unzip terraform_0.11.7_linux_amd64.zip
rm terraform_0.11.7_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Install azure-cli
curl -L https://aka.ms/InstallAzureCli | bash

# Set up symlinks to share files across computers
sudo chown $USER ~/.config
rm ~/.profile
rm ~/.bashrc
rm -rf ~/.ssh
mkdir ~/.kube
rm ~/.kube/config
rm -rf ~/.kube/configs
ln -s /mnt/c/Users/$USER/OneDrive/Documents/Keep/Linux/.profile ~/.profile
ln -s /mnt/c/Users/$USER/OneDrive/Documents/Keep/Linux/.bashrc ~/.bashrc
ln -s /mnt/c/Users/$USER/OneDrive/Documents/Keep/Linux/.ssh ~/.ssh
ln -s /mnt/c/Users/$USER/OneDrive/Documents/Keep/Linux/.kube/config ~/.kube/config
ln -s /mnt/c/Users/$USER/OneDrive/Documents/Keep/Linux/.kube/configs ~/.kube/configs

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
rm ~/.zshrc
ln -s /mnt/c/Users/$USER/OneDrive/Documents/Keep/Linux/.zshrc ~/.zshrc
