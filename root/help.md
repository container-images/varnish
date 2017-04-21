varnish(1) -- HTTP accelerator designed for content-heavy dynamic web sites
==============================================================================

## USAGE

To pull the varnish container run:

      # docker pull modularitycontainers/varnish

To run your application in docker container:

      # docker run -p <PORT>:6081 -p <MANAGEMENT_PORT>:6082 modularitycontainers/varnish

This is the basic execution of the container. `<PORT>` is the cache frontend on which it will serve content. `<MANAGEMENT_PORT>` is port for Varnish admin CLI. To access it, you'll need the varnish secret file. You can also link containers to be used as backend servers, as described in previous section.


# CONFIGURATION

You can find the configuration file default.vcl in **files** folder. This directory also contains the varnish_secret file which is used as an authentification token. **The varnish_secret file needs to be replaced by your own! Otherwise, everyone will be able to access your Varnish admin CLI!** You can generate your own secret.
You can configure servers that are not running on localhost as you would usually, but if you have some servers running locally, there's a little extra work you need to do. I.e. I have container with web server running on port 80 in container and exposed as port 8036 on host. If I wanted to add this container as a backend server, first step would be to get it's name from `docker ps`.

```
$ docker ps
CONTAINER ID    IMAGE    COMMAND                  CREATED              STATUS           PORTS                  NAMES
c756b751d06d    nginx    "/bin/sh -c nginx"       4 minutes ago        Up 4 minutes     0.0.0.0:8036->80/tcp   stupefied_albattani
```

Next step is to edit the varnish configuration with a hostname of your choice. Let's say I want to call this server back1. Then the configuration would look like this:

```
backend back1 {
    .host = "back1";
    .port = "80";
}
```
Note that the port needs to be the one in the container, not in the host. Last step is to link the container itself to your Varnish container. When running the Varnish container, add parameter `--link container_name:hostname` for each backend server running in container from localhost. For my example container I would run it like this:

```
$ docker run -p 6081:6081 -p 6082:6082 --link stupefied_albattani:back1  varnish

```