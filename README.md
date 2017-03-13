# Varnish HTTP Cache container

This repository contains resources for Varnish cache container. This is an example, so it is not recommended to use it in production, but feel free to try it out. It uses fedora:25 with varnish 5.0.0. installed as a base image, Dockerfile for this image is in the **image** folder.

# Configuration

You can find the configuration file default.vcl in **files** folder. This directory also contains the varnish_secret file which is used as an authentification token. **The varnish_secret file needs to be replaced by your own! Otherwise, everyone will be able to access your Varnish admin CLI!** You can generate your own secret as described [here](https://www.varnish-cache.org/docs/4.1/users-guide/run_security.html#cli-interface-authentication). 

## Backend servers

You can configure servers that are not running on localhost as you would usually, but if you have some servers running locally, there's a little extra work you need to do. I.e. I have container with web server running on port 80 in container and exposed as port 8036 on host. If I wanted to add this container as a backend server, first step would be to get it's name from `docker ps`.

```Shell
$ docker ps
CONTAINER ID    IMAGE    COMMAND                  CREATED              STATUS           PORTS                  NAMES
c756b751d06d    nginx    "/bin/sh -c nginx"       4 minutes ago        Up 4 minutes     0.0.0.0:8036->80/tcp   stupefied_albattani
```

Next step is to edit the varnish configuration with a hostname of your choice. Let's say I want to call this server back1. Then the configuration would look like this:

```VCL
backend back1 {
    .host = "back1";
    .port = "80";
}
```
Note that the port needs to be the one in the container, not in the host. Last step is to link the container itself to your Varnish container. When running the Varnish container, add parameter `--link container_name:hostname` for each backend server running in container from localhost. For my example container I would run it like this:

```Shell
$ docker run -p 6081:6081 -p 6082:6082 --link stupefied_albattani:back1  varnish

``` 
You might have noticed some ports are published, which will be explained in the next section

# Running in Docker
There are two ways you can run this container in Docker.

1\) **From shell**

```Shell
docker run -p <PORT>:6081 -p <MANAGEMENT_PORT>:6082
```
This is the basic execution of the container. `<PORT>` is the cache frontend on which it will serve content. `<MANAGEMENT_PORT>` is port for Varnish admin CLI. To access it, you'll need the varnish secret file. Varnish admin CLI is documented [here](https://varnish-cache.org/docs/4.1/reference/varnishadm.html). You can also link containers to be used as backend servers, as described in previous section.

2\) **With a Makefile**

To make it easier for you, this repository contains a Makefile. It can be easily configured to customize running this container to your needs. Note that this Makefile runs container in detached mode (-d flag) by default.
```Makefile
# Docker container tag
IMAGE_NAME = varnish

# Port varnish will serve content on
PORT = 8080

# Port you can later access with varnish admin CLI
MANAGEMENT_PORT = 6082

# Here you can link your other containers to be used as backend servers
# as container_name:hostname
# please note that you have to add the hostname in the configuration too
LINK = 

# Addtional flags for Docker
FLAGS = -d
```
