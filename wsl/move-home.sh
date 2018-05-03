#!/bin/bash
if [ ! -d /Users ]; then
  echo "Creating /Users"
  sudo mkdir /Users
fi
cd $HOME/..
windowsuser=$(cmd.exe /c echo %USERNAME% | tr -d '\r')
if [ ! -d /Users/$windowsuser ]; then
  echo "Moving $HOME to /Users/$windowsuser"
  sudo cp -r $USER /Users/$windowsuser
  sudo chown $USER:$USER /Users/$windowsuser
  sudo sed -i "s,$HOME,/Users/$windowsuser," /etc/passwd
  echo "Now exit this terminal and re-open another shell."
else
  echo "Already moved to /Users/$windowsuser"
fi
