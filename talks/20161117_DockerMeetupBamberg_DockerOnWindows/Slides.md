
class: middle, center, inverse

# Docker on Windows
## Windows Server 2016 and Windows 10

.invisible[
.

.
]

Stefan Scherer [@stefscherer](https://twitter.com/stefscherer)

November 17 2016, Docker Meetup Bamberg

---
background-image: url(assets/chocolatey_captain_mvp.png)
# Who am I?

Software Engineer at SEAL Systems

Maintainer of Docker chocolatey packages

Docker Captain

Microsoft MVP
---
background-image: url(assets/rpi-swarm-cluster.jpg)

noclass: inverse

# Who am I?

Software Engineer at SEAL Systems

Maintainer of Docker chocolatey packages

Docker Captain, Docker Pirate at Hypriot

Microsoft MVP

.invisible[

]
---
class: middle, center
# Windows Containers
---
background-image: url(assets/docker-windows.png)
---
background-image: url(assets/docker-windows.png)
# General availability
--

## Windows Server 2016
--

## Windows 10 Pro
---
# Windows 10 Pro

--
* Anniversary Update 1607 + Windows Updates

--
* Developers can build and run Windows containers locally

--
background-image: url(assets/docker-for-windows.png)
## Docker for Windows
* https://docs.docker.com/docker-for-windows/
* Use Beta channel
* Switch to Windows containers

--

## Direct installation
* https://aka.ms/containers
* Activate Containers feature
* Activate Hyper-V feature
* Install Docker service

---
# Windows Server 2016

--
* All editions: Essentials, Standard, Datacenter
* Nano Server as Container host

--

## Installation
* https://aka.ms/containers

--

* Use Docker package from PSGallery

```powershell
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
Install-Package -Name docker -ProviderName DockerMsftProvider
Restart-Computer -Force
```

--

* The Hyper-V feature is optional


---
background-image: url(assets/windows_containers.png)
---
background-image: url(assets/windows_containers-2.png)
---
background-image: url(assets/windows_containers-3.png)
---
background-image: url(assets/windows_containers-4.png)
---
background-image: url(assets/windows_containers-5.png)
---
background-image: url(assets/windows_containers-6.png)
---
background-image: url(assets/windows_containers-7.png)
---
background-image: url(assets/windows_containers-8.png)
---
background-image: url(assets/isolation_levels-1.png)
# Container isolation - Windows Server 2016

---
background-image: url(assets/isolation_levels-2.png)
# Container isolation - Windows Server 2016

## Windows Server Containers
  * use **same Windows kernel** of container host
  * lightweight, faster

---
background-image: url(assets/isolation_levels-3.png)
# Container isolation - Windows Server 2016

## Windows Server Containers
  * use **same Windows kernel** of container host
  * lightweight, faster

## Hyper-V Containers
  * running in Hyper-V
  * better isolation
  * can use different Windows kernel version
  * `docker run --isolation=hyperv`

---
background-image: url(assets/isolation_levels-4.png)
# Container isolation - Windows 10

## Hyper-V Containers
  * The only option for Windows 10
  * running in Hyper-V
  * must use the Windows Server kernel
  * Automatically uses isolation=hyperv
  * `docker run` without `--isolation` is ok

---
background-image: url(assets/nano_container.png)
# Windows base images

## FROM microsoft/windowsservercore
  * nearly full Win32 compatible
  * about 9 GByte
  * But: Must be downloaded only once
  * Base layer shared with all Windows images

## FROM microsoft/nanoserver
  * fast to boot
  * software may need porting
  * No 32bit, no MSI
  * about 700 MByte

## ~~FROM scratch~~


---
class: middle, center
# Demo time!

---
# Getting Started

## Containers at Microsoft
  * https://microsoft.com/containers

## Windows Container Docs
  * https://aka.ms/windowscontainers

## Community Links
  * https://aka.ms/windowscontainers/community

## Docker Labs
  * https://github.com/docker/labs/tree/master/windows

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

Slides available as Windows container image
```
docker run -p 8000:8000 stefanscherer/talks:2016-11-17
```

.invisible[#


]
