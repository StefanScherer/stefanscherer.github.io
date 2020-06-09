### Task description

### What to do

The agenda is in German, since the recordings will be in German.

Pro Hauptpunkt eine Folge

#### Part 1: Einführung

- [ ] Grundkonzepte
  - [ ] Was ist Docker?
  - [ ] Wie funktioniert Docker?
  - [ ] Container vs Images
  - [ ] Dockerfile - nur ganz grob den Begriff
  - [ ] Registry
  - [ ] Versionierung
  - [ ] Host, Guest, …
- [ ] Installation
  - [ ] ab hier einzelne Videos pro Plattform, sind dann eigene Folgen "1"
  - [ ] macOS (Docker Desktop for Mac)
  - [ ] Windows (Docker Desktop for Windows)
    - [ ] WSL 2 / Windows 10 Home
    - [ ] (ggf. Windows Terminal)
    - [ ] (ggf. Zusammenspiel VirtualBox / VMware)
  - [ ] Linux (Ubuntu)
- [ ] Docker Desktop
  - [ ] Getting Started guide
  - [ ] Dashboard / Kitematic
- [ ] Container verwenden (Teil 1)
  - [ ] docker run
  - [ ] docker stop
  - [ ] docker kill
  - [ ] Port-Forwarding
  - [ ] docker ps
  - [ ] docker logs (Konsole!)
  - [ ] docker system prune

#### Part 2: Grundlagen

- [ ] Docker Desktop Mac / Windows (Teil 2)
  - [ ] Zusammenspiel mit VSCode
- [ ] Erstellen von Images (Teil 1)
  - [ ] Dockerfile
  - [ ] docker build
  - [ ] docker images (Tags)
  - [ ] Layers
  - [ ] docker rmi
- [ ] Container verwenden (Teil 2)
  - [ ] Port-Forwardings in Depth
  - [ ] Environment Variables
  - [ ] Volumes (Named Volumes, Data-Only Container?)
  - [ ] docker rm
  - [ ] docker rm -v
  - [ ] Named Containers
  - [ ] tmpfs
- [ ] Erstellen von Images (Teil 2)
  - [ ] Multi-Stage Builds
  - [ ] Eigene Registry
  - [ ] docker push
  - [ ] docker pull
  - [ ] docker commit
  - [ ] docker save
  - [ ] docker load
  - [ ] Labels
- [ ] Security
  - [ ] PID 1
  - [ ] root-User
  - [ ] Trusted Registries
  - [ ] Daemon über HTTPS
  - [ ] Auditing (?)

#### Part 3: Szenarien

- [ ] Multi-Container Apps
  - [ ] docker-compose
  - [ ] Linken von Containern
  - [ ] Host-Auflösung und Routing
  - [ ] Restart-Policies
  - [ ] Networking
- [ ] (docker-machine) Docker in der Cloud
  - [ ] DOCKER_HOST & Co.
  - [ ] docker context
  - [ ] Remote: Digital Ocean
  - [ ] create, ls, env, rm
- [ ] Clustering
  - [ ] Swarm
  - [ ] Services und Stacks
  - [ ] Labels für Nodes
  - [ ] Node Affinity
  - [ ] Limits und Quotas
  - [ ] HA und Loadbalancing
  - [ ] (Rolling) Updates

#### Part 4: Docker auf IoT / Raspberry Pi

- [ ] Installation
  - [ ] Raspberry Pi (Raspbian)
- [ ] Erstellen von Images (Teil 3)
  - [ ] Multi-Architektur (x86, ARM, …)

#### Part 4: Sonstiges

- [ ] ?
  - [ ] Docker "from scratch"
  - [ ] Images ohne Base-Image bauen
  - [ ] Images von Hand aufbauen
  - [ ] Daemon konfigurieren
- [ ] Ausblick
  - [ ] Kubernetes
  - [ ] AKS, EKS, …
  - [ ] OpenShift
- [ ] Docker-Container für Windows-Anwendungen
