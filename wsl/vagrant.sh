#!/bin/bash

echo "Preparing Vagrant"
if [ ! -e ~/.vagrant.d ]; then
  mkdir -p /mnt/c/Users/$(cmd.exe /c echo %USERNAME% | tr -d '\r')/.vagrant.d
  ln -s /mnt/c/Users/$(cmd.exe /c echo %USERNAME% | tr -d '\r')/.vagrant.d/ ~/.vagrant.d
fi

v=$(dpkg -l | grep vagrant)
if [ "$v" == "" ]; then
  echo "Installing Vagrant"
  wget https://releases.hashicorp.com/vagrant/2.1.0/vagrant_2.1.0_x86_64.deb
  sudo dpkg -i vagrant_2.1.0_x86_64.deb
  rm vagrant_2.1.0_x86_64.deb
  export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1
fi

echo "Preparing Vagrant VMware"
if [ ! -e /opt/vagrant-vmware-desktop ]; then
  if [ -e /mnt/c/ProgramData/HashiCorp/vagrant-vmware-desktop ]; then
    sudo ln -s /mnt/c/ProgramData/HashiCorp/vagrant-vmware-desktop /opt/vagrant-vmware-desktop
  else
    sudo ln -s /mnt/c/ProgramData/hashicorp/vagrant-vmware-desktop /opt/vagrant-vmware-desktop
  fi
fi
vagrant plugin install vagrant-vmware-desktop


if [ -d /opt/vagrant/embedded/gems/2.1.0 ]; then
  echo "Fixing Vagrant 2.1.0 vmrun and shared folders"
  wget https://raw.githubusercontent.com/StefanScherer/dotfiles/master/bin/vmrun.exe-helper
  chmod +x vmrun.exe-helper
  sudo cp vmrun.exe-helper "/usr/bin/C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe"
  rm vmrun.exe-helper
fi

if [ ! -f ~/.vagrant.d/license-vagrant-vmware-desktop.lic ]; then
  echo "Now run the following command"
  echo "  vagrant plugin license vagrant-vmware-desktop ./license.lic"
fi

echo "Please add the following command to your ~/.bashrc"
echo "  export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1"
