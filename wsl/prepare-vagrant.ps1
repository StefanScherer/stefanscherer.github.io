if (!(Test-Path C:\ProgramData\chocolatey\bin\choco.exe)) {
  Write-Host "Installing Chocolatey"
  iwr -useb https://chocolatey.org/install.ps1 | iex
}

if (!(Test-Path "C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe")) {
  Write-Host "Installing VMware Workstation"
  choco install -y vmwareworkstation
}

if (!(Test-Path C:\HashiCorp\VagrantVMwareUtility\bin\vagrant-vmware-utility.exe)) {
  Write-Host "Installing Vagrant VMware Utility"
  choco install -y vagrant-vmware-utility
}

if (Test-Path C:\HashiCorp\Vagrant\bin\vagrant.exe) {
  Write-Host "Uninstalling Vagrant"
  choco uninstall vagrant
}

if (!(Test-Path C:\mnt\c\Users)) {
  Write-Host "Creating symlink for Linux Vagrant 2.0.4"
  choco uninstall vagrant
  mkdir C:\mnt\c\Users 
  $windowsuser=((tasklist /V | sls explorer.exe) -split " +")[7] -replace ".*\\", ""
  if (Test-Path C:\Users\$windowsuser) {
    if (!(Test-Path C:\mnt\c\Users\$windowsuser)) {
      Write-Host "Creating symlink for C:\Users\$windowsuser"
      cmd /c mklink /D C:\mnt\c\Users\$windowsuser C:\Users\$windowsuser
    }
  }
}
