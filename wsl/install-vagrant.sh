#!/bin/bash

echo "Preparing Vagrant"
if [ ! -e ~/.vagrant.d ]; then
  mkdir -p /mnt/c/Users/$(cmd.exe /c echo %USERNAME% | tr -d '\r')/.vagrant.d
  ln -s /mnt/c/Users/$(cmd.exe /c echo %USERNAME% | tr -d '\r')/.vagrant.d/ ~/.vagrant.d
fi

echo "Installing Vagrant"
wget https://releases.hashicorp.com/vagrant/2.0.4/vagrant_2.0.4_x86_64.deb
sudo dpkg -i vagrant_2.0.4_x86_64.deb
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1

echo "Preparing Vagrant VMware"
sudo ln -s /mnt/c/ProgramData/HashiCorp/vagrant-vmware-desktop /opt/vagrant-vmware-desktop
vagrant plugin install vagrant-vmware-desktop


if [ -d /opt/vagrant/embedded/gems/2.0.4/gems/vagrant-2.0.4/plugins ]; then
  echo "Fixing Vagrant 2.0.4 vmrun and shared folders"
  wget https://raw.githubusercontent.com/StefanScherer/dotfiles/master/bin/vmrun.exe-helper
  chmod +x vmrun.exe-helper
  sudo cp vmrun.exe-helper "/usr/bin/C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe"
  rm vmrun.exe-helper
fi

if [ -f /opt/vagrant/embedded/gems/2.0.4/gems/vagrant-2.0.4/plugins/hosts/linux/cap/rdp.rb ]; then
  echo "Fixing vagrant rdp"
  wget https://github.com/StefanScherer/vagrant/blob/wsl-rdp/plugins/hosts/linux/cap/rdp.rb
  sudo mv rdp.rb /opt/vagrant/embedded/gems/2.0.4/gems/vagrant-2.0.4/plugins/hosts/linux/cap/rdp.rb
fi

if [ -f /opt/vagrant/embedded/gems/2.0.4/gems/vagrant-2.0.4/plugins/providers/virtualbox/driver/base.rb ]; then
  echo "Fixing vagrant status"
  wget https://github.com/StefanScherer/vagrant/blob/wsl-remove-raise-vboxmanage-missing/plugins/providers/virtualbox/driver/base.rb
  sudo mv base.rb /opt/vagrant/embedded/gems/2.0.4/gems/vagrant-2.0.4/plugins/providers/virtualbox/driver/base.rb
if
