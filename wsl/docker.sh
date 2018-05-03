#!/bin/bash
if [ ! -f /usr/bin/docker ]; then
  echo "Install Docker CLI"
  cd /tmp
  curl https://download.docker.com/linux/static/edge/x86_64/docker-18.04.0-ce.tgz | tar xzf -
  sudo mv docker/docker /usr/bin/docker
  rm -rf docker
fi

if [ ! -f /usr/bin/docker-compose ]; then
  echo "Install Docker Compose"
  cd /tmp
  curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o docker-compose
  chmod +x docker-compose
  sudo mv docker-compose /usr/local/bin/docker-compose
fi

if [ ! -e ~/.docker ]; then
  echo "Link .docker"
  mkdir -p /mnt/c/Users/$(cmd.exe /c echo %USERNAME% | tr -d '\r')/.docker
  ln -s /mnt/c/Users/$(cmd.exe /c echo %USERNAME% | tr -d '\r')/.docker/ ~/.docker
fi
