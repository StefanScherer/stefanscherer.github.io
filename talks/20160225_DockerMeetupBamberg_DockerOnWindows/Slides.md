
class: middle, center, inverse

## Current status of
# Docker on Windows

.invisible[
.

.
]

Stefan Scherer [@stefscherer](https://twitter.com/stefscherer)

February 25 2016, Docker Meetup Bamberg
---
# Who am I?
---
# Who am I?

Software Engineer at SEAL Systems
---
# Who am I?

Software Engineer at SEAL Systems

Docker chocolatey package maintainer
---
background-image: url(assets/rpi-swarm-cluster.jpg)

noclass: inverse

# Who am I?

Software Engineer at SEAL Systems

Docker chocolatey package maintainer

Docker Pirate

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
background-image: url(assets/windows_container_host.png)

# System architecture
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
background-image: url(assets/swarm.png)
.left-column[
  ## Swarm
]
.right-column[
* Works
* Networking is tricky with TP4
* Multi architecture swarm cluster demo at DockerCon
]
---
background-image: url(assets/compose.png)
.left-column[
  ## Swarm
  ## Compose
]
.right-column[
* Works, but ...
* Networking is tricky with TP4
* No links
* Tried `net: none`
* Can't wait for TP5!
]
---
background-image: url(assets/machine.png)
.left-column[
  ## Swarm
  ## Compose
  ## Machine
]
.right-column[
* Works for Linux Docker Engines
* No `docker-machine create -d` for TP4 at the moment
* Discussion in [docker/machine#2907](https://github.com/docker/machine/issues/2907)
]
---
background-image: url(assets/registry.png)
.left-column[
  ## Swarm
  ## Compose
  ## Machine
  ## Registry
]
.right-column[
* Works for Windows Containers, serving from Linux
* `docker pull` from private Registry
* `docker push` to private Registry
]
---
class: middle, center, inverse
# Where to go next?
---
background-image: url(assets/azure_win_mac.png)
# Try it yourself

## Azure
  * ["Deploy to azure"](https://github.com/StefanScherer/docker-windows-azure)

## Local

### Windows 10 + Hyper-V
  * [Blog post](https://msdn.microsoft.com/en-us/virtualization/windowscontainers/quick_start/container_setup)

### Others
  * [packer build](https://github.com/StefanScherer/packer-windows)
  * [vagrant up](https://github.com/StefanScherer/docker-windows-box)
  * VirtualBox, VMware
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
