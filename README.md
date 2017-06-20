# Varnish HTTP Cache container

This repository contains resources for Varnish cache container. This is an example, so it is not recommended to use it in production, but feel free to try it out. It uses Fedora 26 Boltron as a base image with Varnish installed as a module.

# Configuration

You can find the configuration file default.vcl in **files** folder. Varnish secret file is generated each time the container is built, for better security. While this provides *some* security, we strongly advise you always use your own secret (see below in [Running in Docker](#Running-in-Docker)) or do not expose `<MANAGEMENT_PORT>` if you don't need it.

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
$ docker run -p 6081:6081 -p 6082:6082 --link stupefied_albattani:back1 -v <CONFIG_DIR>:/varnish_config/

``` 
You might have noticed some ports are published and some volume is mounted, which will be explained in the next section.

# Running in Docker
There are two ways you can run this container in Docker.

1\) **From shell**

```Shell
docker run -p <PORT>:6081
```
This is the basic execution of the container. `<PORT>` is the cache frontend on which it will serve content. Varnish has it's own admin CLI (see `<MANAGEMENT_PORT>` below). To access it, you'll need the varnish secret file. Varnish admin CLI is documented [here](https://varnish-cache.org/docs/4.1/reference/varnishadm.html). You can mount your secret file, that has to be named varnish_secret like this:

```Shell
docker run -p <PORT>:6081 -p <MANAGEMENT_PORT>:6082 -v <SECRET_DIR>:/varnish_secret/
```

If you want to use your configuration instead of the default one, name it default.vcl and mount it like this:


```
docker run -p $PORT:6081 -v <CONFIG_DIR>:/varnish_config/
```

Where `<CONFIG_DIR>` is a directory that contains default.vcl file.

If mounting gives you an error, it might be due to SELinux, you can then apply following:

```
chcon -Rt svirt_sandbox_file_t <DIR>
```

You can also link containers to be used as backend servers, as described in previous section.

2\) **With a Makefile**

To make it easier for you, this repository contains a Makefile. It can be easily configured to customize running this container to your needs. Note that it does not provide a way to mount varnish_secret or custom configuration. Feel free to edit it to your needs
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
FLAGS = 
```

# Running in Openshift
To run this container in OpenShift, you need to change the `RunAsUser` option in the `restricted` Security Context Constraint (SCC) from `MustRunAsRange` to `RunAsAny`. Do it by running:

```Shell
$ oc login -u system:admin
$ oc project default
$ oc edit scc restricted
```

Find `RunAsUser` and change its value from `MustRunAsRange` to `RunAsAny`. This is needed as varnish root proccess uses this privilege to sandbox child processes.

Then you can run `openshift-template.yml` in this repository:

```Shell
$ oc login -u developer
$ oc create -f openshift-template.yml
```