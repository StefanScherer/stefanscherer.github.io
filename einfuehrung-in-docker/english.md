# Script for episode 1

Hello and welcome to a new video series.

---

Today's first episode of "Introduction to Docker" deals with the basic concepts around Docker and containers.

After this episode, you already know the most important terms and know where the advantages and areas of application of Docker are.

---

My name is Stefan Scherer and I have been working as a software engineer for many years.

I have had my first experience with Docker since mid-2014. After trying it out for the first time, this topic fascinated me more and I became active in the community and gave lectures at meetups and conferences.

Through my community activities, I became Docker Captain and Microsoft MVP.

For the Raspberry Pi, we simplified the use of Docker in a small team, which quickly resulted in our own distribution HypriotOS.

I am also enthusiastic about the wide range of Docker and so I like to blog about Windows Containers.

I have been working for Docker since 2019 and work for the Docker Desktop Team there. I also look after our entire CI infrastructures with all supported platforms.

I am still loyal to the community and available for questions. The best way to reach me is via Twitter or GitHub.

---

At the beginning of each episode, I'll give you a brief overview of what we're going to do.

In this first episode, we start at the very beginning. We're not going to install anything on your computer today, so you don't need to prepare anything yet.

But today we're going to give a few practical examples towards the end.

First of all, I explain why one should deal with containers and what is the attraction of running applications in containers.

We take a brief look at virtual machines and how containers differ in comparison.

I also show what Docker is and why it kind of started a revolution and made containers so popular.

You will also learn how Docker works and how you can easily distribute and start applications on any computer. Based on a typical process, I also introduce you to the four most important terms so that you can then classify them well.

At the end of this episode, you really know the basics of containers and dockers.

---

So why should you deal with containers?

I would like to show you this using a sample application.

---

So let's take a look at how an application is operated on a server.

First the application has to be installed, this usually still needs dependencies, such as libraries or a runtime environment.

Furthermore, the application is configured in a certain form so that it meets the specific requirements.

In this example, the computing capacity is still sufficient, so a second application that requires the same libraries is installed on the server. Everything is going well.

But what happens if there is a new version of this second application?

In the past you might have stopped the application and then started the update. It may be necessary to import new runtime environments. Only after this update did you notice whether the new version works on the computer or not. If there is a problem, it is very difficult to revert to the previous version.

A bigger update of the second application may come out later and new libraries are used there that are incompatible.
This is fine for application 2, but this creates a problem with the first application. It has not yet been adapted to the new library, the update will come later.

Now you have a conflict because you have created dependencies between the applications on one computer.

What you want to achieve is that applications are easier to exchange and do not affect each other. This is where the idea of ​​containers comes into play.

A container is not a hard boundary like its own computer, rather a logical boundary, it is like a fence around the application.

---

Within this limit is the application with everything it needs to run. So you logically separate the operating system from the application.

---

With this concept, each application is operated in its own container. The update of application 2 no longer causes problems with the other applications.
Applications can also be removed cleanly, there really is nothing left on the server.

Containers make it very easy to run two different versions of the application on the same computer and quickly switch from the old to the new version. And also back to the old version if the update does cause problems.

---

Containers have also simplified the transportation of goods. Thanks to the standard sizes, they can be easily transported on ships, trucks or trains.

Such application containers are also standardized in the software.

Each application container is started in the same way, with a precise initial state that development has determined.

Since all dependencies exist, it is clear how the application behaves when it starts.

And this is the same whether you start the container locally on a developer computer or on a server at the customer.

There are other defined interfaces, something like how network ports to the host or other containers can be used.

Each container receives its own IP address and its own host name. When used in a container, it feels as if it is running on its own computer.

Another standardized interface is volumes, so that files and directories can be saved permanently. We'll take a closer look at that in later episodes.

---

Let's look at the difference between virtual machines and containers in the image below.

Perhaps you thought in the example earlier that the applications could have been packed into virtual machines. Right, that would look like the picture on the left.

Two VMs are started, each of which requires a guest operating system. This has to be booted, and then the respective application can be started.

A hypervisor is required on the server to start the virtual machines and allocate them resources such as disk space and memory.

In contrast, containers are much lighter. In the picture on the right, containers run directly in the operating system of the server. The intended "fence" for a separate file system with the program files and the runtime libraries is achieved with the operating system means.

Docker is installed on the server and simplifies the control of containers.

No guest operating system has to be booted to start the applications, instead the application is started immediately. It usually started in a few seconds, much faster than you could boot a virtual machine.

Containers use the kernel of the operating system of the server, there are so-called namespaces and other mechanisms in the kernel to realize this logical limit of a container.

For example, you can see all processes from all containers on the server. In a container, however, you only see the processes that run within this container.

The same applies to the file system, within the container you can only see the desired file system that is required for the application.

---

Now that we've learned a few details about Linux containers, the question arises as to what Docker is exactly.

---

Docker was introduced to the audience at a Python conference in 2013. You can find the video on Youtube if you are looking for Future of Linux Containers.

The then dotCloud company simplified the recurring problems when operating applications on servers in the cloud. In the lecture a small command line tool called "Docker" was shown live, with which the whole mechanisms that exist in Linux are simplified to a simple command set.

docker run image

As a result, they sparked interest in the community in many meetups, so work continued on the open source project quickly.

Thanks to the simple concept, the Docker topic became very popular and became a quasi-standard in the software industry.

DotCloud later became Docker Inc. - based in Silicon Valley, which still maintains the Docker tool today.

In the meantime, an enterprise platform was created, which was sold to Mirantis at the end of 2019. Docker Inc. is currently focusing on developer tools and services that I will discuss later.

---

Docker consists of several tools.

For development on macOS and Windows operating systems, Docker Desktop is a tool for running local containers and also packing applications into containers.

Containers are 99% Linux containers. With Docker Desktop, the basis must still be created using a Linux VM to operate on Mac and Windows Linux containers. Docker Desktop brings everything with it and uses the operating system's own hypervisor.

With the Docker Hub - probably the best known container registry - and the contained official images for different programming languages ​​and applications, this revolution could even arise. Because the Docker Hub makes it possible to exchange applications between different developers and computers.

Then there is the Docker engine, which we saw briefly in the previous picture. This is a service that runs on a Linux computer, or in the case of Mac and Windows in a Linux VM. This can be addressed via API and the Docker CLI and controls the start of containers, the downloading and uploading of container images and so on.

Docker also has other tools that we will look at in a later episode. This small overview is sufficient for today.

---

I started explaining what the Docker Engine does. In the following minutes I would like to show you how Docker works, then it becomes clear what makes it so appealing.

---

Along the example, you will also become familiar with the following four terms.

I have summarized them on this slide, you can take this slide as a marker, what is meant by each term.

Let's start from the beginning. First there is the so-called Docker file.

A Dockerfile is a text file, in which you basically enter the building instructions to install your application. Docker can interpret this file and uses it to create an image - an image of your finished application. We see an example of what a Dockerfile looks like.

The image contains the file system with your application and all required files and dependencies. An image is sometimes called a container image or Docker image.

A registry also plays an important role. A registry is a central library for storing and reloading finished images. The Docker Hub is just such a registry, just with a better known name. You can also run your own registries or use one from other cloud providers.

The fourth is the term container. When we speak of a container, we mean a running application that is started from a prepared image.

I would like to show you these four terms again using a typical procedure, how to create an application on your own computer, which should then be operated on another Linux server.

---

On the left is our own research, on the right you can see the server on which we want to run the applications later.

It starts with a Dockerfile.

---

We use the Dockerfile to create an image with the command "docker build". The image is then also stored locally on your own computer.

The Dockerfile may contain commands such as the installation of required runtime environments or packages, it is also conceivable to call compilers to create an executable program from the source code in the first place.

A Docker file enriches your own source codes and is also included as such in the source code management. So you have versioned the building instructions.

How do we get the image on the other computer?

---

There is the command "docker push" to upload an image into a registry. Images are given names and so-called tags, which contain a version number, for example. This allows you to keep multiple versions in the registry.

---

Docker is also installed on the server. With the command "docker pull" images can now be downloaded from the registry to the server.

The image contains all the necessary files and directories for the respective application.

---

Last but not least, there is the "docker run" command to start a container. A container starts with the file system image of the image and our application starts on the server.

In principle, that's all you need to know to understand containers and dockers.

Docker's great popularity comes from these few commands that made it easier to create images.

Also of great importance is the registry, the Docker Hub, where high-quality images are available with a variety of official images.

Because that's what containers are all about, nobody has to start from scratch, but builds on existing images in the Docker Hub to build their own application images.

In the next slide I will show you a Dockerfile so that you can get an idea of ​​how such a construction manual looks like.

---

A Dockerfile is a text file, almost like any other source code.

The Dockerfile shown here packs the Apache web server into an image so that we can start our own web server in a container, for example.

The Dockerfile now describes line by line what needs to be done so that we install the executable program and all required dependencies.

There are several commands that Docker interprets when an image is built from the Docker file.

At the beginning of each Docker file there is a line with "FROM".

FROM tells you which base image you want to start with. As I said, you don't have to start from scratch. You can use one of the many official images, such as a desired Linux distribution.

In this example we use the debian base image and therefore write "FROM debian".

Where do you get the names of the official images?

In the Docker Hub you can look for images and there are also short descriptions. So let's take a quick look at the Docker Hub to learn more about the Debian image.

---
switch to browser
open docker hub
search debian
show tags, readme, ...
show other official images
---

The next lines always start with "RUN". This means that the following command should be executed when building the image.

Since we use Debian as the base image, the apt-get command calls the Debian package manager. We update the package manager first and in the next command we install the package called apache2.

The next command creates a directory in the image because it will be needed later at runtime.

Now comes a new command: EXPOSE

We are telling Docker that this image uses network port 80. This is just information that can later be read from the image and helps the user of the image to understand which port our web server is listening on.

The CMD command is often at the end of a Docker file.
As you can see here, it defines the command that should be called when a container is started.

So we developers already define how our container will be started later.

There are, of course, other commands that you will learn about in subsequent episodes.

But for our example with the Apache web server, this Dockerfile is enough.

---

If we now build an image with "docker build", the Dockerfile is interpreted line by line.

A small delta is created in the file system for each line - a so-called layer, or image layer.

With FROM debian, the debian image is initially used as the basis with all the files it contains.

The first RUN command updates the package lists, which usually loads new files from the Internet and stores them in the file system.

From now on you have access to the current packages from Debian. At the end of the RUN command, this layer is closed and stored locally.

The second RUN command now installs the Apache2 web server with all required packages.

I've written the approximate sizes here in each layer that is needed locally.

The layer is also completed here, each RUN command does not write anything to the previous layer.

So it goes on command by command, to EXPOSE and CMD, which only create metadata.

At the end of the construction process, the finished image is now stored locally.

---

Let's take a look at the difference between an image and a container in the following image. That was the biggest hurdle for me at the beginning and always caused confusion.

If we now start a container, we enter the name of an image at the start.

In this case it would be our Apache image.

A running container is still assigned a writable layer for the runtime.

The Apache web server can read and write files, for example, lck files or log files are written.

However, these do not end up in the image, this is protected against changes.

Each container has its own file system, in which the lck file and log files can be written independently of other containers.

It is therefore possible to run multiple instances on one computer.

So the difference between image and container is:

An image is the static image of the file system, so to speak a photo of how it should look at the start.

A container starts a copy of the image, and the processes in the container have the ability to make changes to the file system at runtime.

Let's try out what we have just learned in practice.

---

I said yes that we don't install anything locally on your computer yet.

Instead, we use another Docker service - Play with Docker - to simply carry out the first steps in the browser.

What we will do in the next few minutes is to go back to the Docker Hub and create an account there.

Don't worry, it's free and doesn't require a credit card.

It is simply used to protect the Play with Docker service against misuse. We are provided with a small virtual Linux environment with Docker. We will also use the Docker Hub Account in other episodes to store our images permanently.

---
open docker hub
sign up, confirm email
---
open play with docker
sign in
create instance
---

Now that we have started a Play with Docker environment, we have a Linux terminal.

For this video series there are also examples on GitHub that you can use so that you don't have to type everything out of the video.

With the command "git clone" we download the examples into the Play with Docker instance.

In the 01-grundkonzepte folder you will find the Dockerfile from the slide further up.

Next we look at the Dockerfile again.

---

Now we can create the image.

docker build -t apache2.

---

With the command "docker images" we can check which images have been downloaded or built locally.

As you can see, two images are listed here, first the base image debian and our freshly built apache2 image.

Now we start a container

docker run -d -p 8080: 80 apache2

I purposely used different ports between the host and the container to better show which one is for the host and which is for the container.

My donkey bridge as I remember it, from left to right you go from the browser to the host port to the container port like the network route.

docker ps
docker kill
browser close or quit

---

And that's the end of the first episode.

I hope I was able to teach you the basics of Docker and give you an introduction to the topic. You are welcome to try something else on Play with Docker or close the browser at the end.

In the next episode I will show you how to install Docker locally on your computer.

Then you have the opportunity to practice the scenario shown earlier - build locally, upload to the Docker Hub and then start a container.

If you have any questions or suggestions, please feel free to contact me on Twitter.

Bye until next time.
