#!/bin/bash
if [ ! -f /usr/bin/docker ]; then
  cd /tmp
  curl https://download.docker.com/linux/static/edge/x86_64/docker-18.04.0-ce.tgz | tar xzf -
  sudo mv docker/docker /usr/bin/docker
  rm -rf docker
fi
