#!/bin/bash

echo "Preparing Vagrant"
if [ ! -e ~/.vagrant.d ]; then
  mkdir -p /mnt/c/Users/$(cmd.exe /c echo %USERNAME% | tr -d '\r')/.vagrant.d
  ln -s /mnt/c/Users/$(cmd.exe /c echo %USERNAME% | tr -d '\r')/.vagrant.d/ ~/.vagrant.d
fi

VAGRANT_VERSION=2.1.1

if [ "$(dpkg -l | grep vagrant)" == "" ]; then
  echo "Installing Vagrant"
  wget https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_x86_64.deb
  sudo dpkg -i vagrant_${VAGRANT_VERSION}_x86_64.deb
  rm vagrant_${VAGRANT_VERSION}_x86_64.deb
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


if [ -d /opt/vagrant/embedded/gems/${VAGRANT_VERSION} ]; then
  echo "Fixing Vagrant ${VAGRANT_VERSION} vmrun and shared folders"
  wget https://raw.githubusercontent.com/StefanScherer/dotfiles/master/bin/vmrun.exe-helper
  chmod +x vmrun.exe-helper
  sudo cp vmrun.exe-helper "/usr/bin/C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe"
  sudo ln -s '/usr/bin/C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe' /usr/bin/vmrun
  rm vmrun.exe-helper
fi

if [ ! -f ~/.vagrant.d/license-vagrant-vmware-desktop.lic ]; then
  echo "Now run the following command"
  echo "  vagrant plugin license vagrant-vmware-desktop ./license.lic"
fi

echo "Please add the following command to your ~/.bashrc"
echo "  export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1"
