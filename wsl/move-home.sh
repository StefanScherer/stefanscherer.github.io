#!/bin/bash
sudo mkdir /Users
cd $HOME/..
windowsuser=$(cmd.exe /c echo %USERNAME% | tr -d '\r')
sudo cp -r $USER /Users/$windowsuser
sudo chown $USER:$USER /Users/$windowsuser
sudo sed -i "s,$HOME,/Users/$windowsuser," /etc/passwd
exit
