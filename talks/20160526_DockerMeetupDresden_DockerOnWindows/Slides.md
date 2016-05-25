
class: middle, center, inverse

## Current status of
# Docker on Windows Server 2016 TP5

.invisible[
.

.
]

Stefan Scherer [@stefscherer](https://twitter.com/stefscherer)

May 26 2016, Docker Meetup Dresden
---
# Who am I?
---
# Who am I?

Software Engineer at SEAL Systems
---
background-image: url(assets/chocolatey.png)
# Who am I?

Software Engineer at SEAL Systems

Docker chocolatey package maintainer
---
background-image: url(assets/chocolatey_docker_captain.png)
# Who am I?

Software Engineer at SEAL Systems

Docker chocolatey package maintainer

Docker Captain
---
background-image: url(assets/rpi-swarm-cluster.jpg)

noclass: inverse

# Who am I?

Software Engineer at SEAL Systems

Docker chocolatey package maintainer

Docker Captain, Docker Pirate at Hypriot

.invisible[

]
---
class: middle, center, inverse
# Windows Containers
---
class: middle, center, inverse
## What is it all about?
---
.left-column[
  ## What is it?
]
.right-column[
A lightweight virtualization for applications

.invisible[
.
]
]
---
background-image: url(assets/vm-docker.png)

.left-column[
  ## What is it?
]
.right-column[
A lightweight virtualization for applications

Smaller than VM's
]
---
background-image: url(assets/vm-docker.png)

.left-column[
  ## What is it?
]
.right-column[
A lightweight virtualization for applications

Smaller than VM's

Just the files needed to run the application
]
---
.left-column[
  ## What is it?
  ## Why use it?
]
.right-column[
]
---
background-image: url(assets/build_ship_run_container_only.png)
.left-column[
  ## What is it?
  ## Why use it?
]
.right-column[
# Build - Ship - Run
]
---
background-image: url(assets/build_ship_run_dev.png)
.left-column[
  ## What is it?
  ## Why use it?
]
.right-column[
# Build - Ship - Run

- Reproducible development environment

.invisible[
.
]
]
---
background-image: url(assets/build_ship_run_dev.png)
.left-column[
  ## What is it?
  ## Why use it?
]
.right-column[
# Build - Ship - Run

- Reproducible development environment

- Same container in dev
]
---
background-image: url(assets/build_ship_run_dev_test.png)
.left-column[
  ## What is it?
  ## Why use it?
]
.right-column[

# Build - Ship - Run

- Reproducible development environment

- Same container in dev, test

]
---
background-image: url(assets/build_ship_run.png)
.left-column[
  ## What is it?
  ## Why use it?
]
.right-column[

# Build - Ship - Run

- Reproducible development environment

- Same container in dev, test and prod
]
---
background-image: url(assets/build_ship_run.png)
.left-column[
  ## What is it?
  ## Why use it?
]
.right-column[

# Build - Ship - Run

- Reproducible development environment

- Same container in dev, test and prod

- Containers are versioned
]
---
background-image: url(assets/build_ship_run_container_only.png)
.left-column[
  ## What is it?
  ## Why use it?
  ## How does it work?
]
.right-column[
]
---
background-image: url(assets/build_ship_run_container_only.png)
.left-column[
  ## What is it?
  ## Why use it?
  ## How does it work?
]
.right-column[
# Namespaces

* File System
]
---
background-image: url(assets/build_ship_run_container_only.png)
.left-column[
  ## What is it?
  ## Why use it?
  ## How does it work?
]
.right-column[
# Namespaces

* File System

* Process IDs
]
---
background-image: url(assets/build_ship_run_container_only.png)
.left-column[
  ## What is it?
  ## Why use it?
  ## How does it work?
]
.right-column[
# Namespaces

* File System

* Process IDs

* Registry
]
---
background-image: url(assets/three_containers.png)
.left-column[
  ## What is it?
  ## Why use it?
  ## How does it work?
]
.right-column[
# Namespaces

* File System

* Process IDs

* Registry

* Networking
]
---
class: middle, center, inverse

# How does it look like?
---
background-image: url(assets/windows_no_container.png)

## System architecture
---
background-image: url(assets/windows_container.png)

## System architecture
---
background-image: url(assets/windows_container_2.png)

## System architecture
---
background-image: url(assets/windows_container.png)

## System architecture
---
background-image: url(assets/windows_container_hyperv_container.png)

## System architecture
---
# Container types

## Windows Server Containers
  * use same Windows kernel
  * lightweight, faster

## Hyper-V Containers
  * running in Hyper-V
  * better isolation
  * `docker run --isolation=hyperv`

---
background-image: url(assets/nano_container.png)
# Base container images

## Windows Server Core
  * nearly full Win32 compatible
  * about 9 GByte

## Nano Server
  * fast to boot
  * software may need porting
  * about 700 MByte

## ~~FROM scratch~~
  * Base images must be preinstalled on Container Host


---
class: middle, center, inverse
# Demo time!
---
class: middle, center, inverse
# What about other Docker tools?
---
background-image: url(assets/registry.png)
.left-column[
  ## Registry
]
.right-column[
* **Docker Hub works with TP5**: `docker pull` and `docker push`
* Private Registry works for Windows Containers, serving from Linux
* Experimental using a Windows private Registry
]
---
background-image: url(assets/swarm.png)
.left-column[
  ## Registry
  ## Swarm
]
.right-column[
* Works
* Networking still work in progress
* Multi architecture swarm cluster demo at DockerCon
* inofficial: `docker pull stefanscherer/swarm-windows`
]
---
background-image: url(assets/compose.png)
.left-column[
  ## Registry
  ## Swarm
  ## Compose
]
.right-column[
* Works: Volumes, Ports
* Networking is still tricky with TP5
  * No links, no DNS right now
  * Use container IP from host
* [docker/compose#2641](https://github.com/docker/compose/issues/2641)
]
---
background-image: url(assets/machine.png)
.left-column[
  ## Registry
  ## Swarm
  ## Compose
  ## Machine
]
.right-column[
* Works for Linux Docker Engines
* No `docker-machine create -d` for TP5 at the moment
* WIP PR [docker/machine#3329](https://github.com/docker/machine/issues/3329) for Azure TP4 VM
]
---
class: middle, center, inverse
# Where to go next?
---
background-image: url(assets/azure_win_mac.png)
# Try it yourself

## Azure
  * ["Deploy to azure"](https://github.com/Azure/azure-quickstart-templates/tree/master/windows-server-containers-preview)

## Local

### Windows 10
  * Hyper-V [Blog post](https://msdn.microsoft.com/en-us/virtualization/windowscontainers/quick_start/container_setup)
  * Windows 10 Insider 14342 + Containers

### Others
  * [packer build](https://github.com/StefanScherer/packer-windows)
  * [vagrant up](https://github.com/StefanScherer/docker-windows-box)
  * VirtualBox, VMware
---
# Resources

## Learn more about Windows Containers
  * http://aka.ms/containers

## Continue providing feedback and bug reports

  * http://aka.ms/containers/forum
  * https://github.com/Microsoft/Virtualization-Documentation
  * https://github.com/docker/docker
---
class: left, inverse

.invisible[#

#

]

# Thank you!


.invisible[#

]

## Stefan Scherer
### [@stefscherer](https://twitter.com/stefscherer)
### [github.com/StefanScherer](https://github.com/StefanScherer)
### scherer_stefan@icloud.com

.invisible[#


]
