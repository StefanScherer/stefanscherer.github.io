#!/bin/bash

echo "Preparing Vagrant"
mkdir -p /mnt/c/Users/$(cmd.exe /c echo %USERNAME% | tr -d '\r')/.vagrant.d
ln -s /mnt/c/Users/$(cmd.exe /c echo %USERNAME% | tr -d '\r')/.vagrant.d/ ~/.vagrant.d

echo "Installing Vagrant"
wget https://releases.hashicorp.com/vagrant/2.0.4/vagrant_2.0.4_x86_64.deb
sudo dpkg -i vagrant_2.0.4_x86_64.deb
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1

echo "Preparing Vagrant VMware"
sudo ln -s /mnt/c/ProgramData/HashiCorp/vagrant-vmware-desktop /opt/vagrant-vmware-desktop
vagrant plugin install vagrant-vmware

echo "Patching Vagrant"
chmod +x "/usr/bin/A
C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe"
wget https://raw.githubusercontent.com/StefanScherer/dotfiles/master/bin/vmrun.exe-helper
chmod +x vmrun.exe-helper
sudo cp vmrun.exe-helper "/usr/bin/C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe"
rm vmrun.exe-helper


