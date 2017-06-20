% VARNISH (1) Container Image Pages
% Jan Koscielniak
% June 20, 2017

# NAME
varnish - HTTP accelerator designed for content-heavy dynamic web sites

# DESCRIPTION
This container image provides the varnish HTTP reverse proxy. It uses Fedora 26 Boltron as a base image with Varnish installed as a module.

Varnish secret file is generated each time the container is built, for better security. While this provides *some* security, we strongly advise you always use your own secret (see below) or do not expose $MANAGEMENT_PORT if you don't need it.

# USAGE
You can run this image in docker like this:

      # docker run -p $PORT:6081

This is the basic execution of the container. $PORT is the port of the varnish frontend on which it will serve content. Varnish has it's own admin CLI (see $MANAGEMENT_PORT below). To access it, you'll need the varnish secret file. Please refer to varnish documentation on how to generate it. You can mount your secret file, that has to be named varnish_secret like this:

	# docker run -p $PORT:6081 -p $MANAGEMENT_PORT:6082 -v $SECRET_DIR:/varnish_secret/
	
If that gives you an error, it might be due to SELinux, you can then apply the following:

	# chcon -Rt svirt_sandbox_file_t $SECRET_DIR

If you want to use your configuration instead of the default one, name it default.vcl and mount it like this:

	# docker run -p $PORT:6081 -v $CONFIG_DIR:/varnish_config/

Where $CONFIG_DIR is a directory that contains default.vcl file.

You can also link containers which you can use as backend servers. You need to run the container you want to use as backend, get it's name or hash, and then edit the configuration file with a hostname you choose for the container. Then run it like this:

	# docker run -p  $PORT:6081 --link container_name:hostname 


Image can also be run in Openshift. You can obtain the template in the repository of this image - https://github.com/container-images/nginx. You also need to have SCC RunAsUser set to RunAsAny. Then run:

	# oc create -f openshift-template.yml

# ENVIRONMENT VARIABLES
There are no environment variables to be set.

# SECURITY IMPLICATIONS
-p $PORT:6081
	Exposes port 6081 on the container and forwards it to $PORT on the host. This is the varnish frontend.

-p $MANAGEMENT_PORT:6082
	Exposes port 6082 on the container and forwards it to $MANAGEMENT_PORT on the host. This is varnish admin CLI.

-v $SECRET_DIR:/varnish/
	Mounts a directory with varnish_secret file, that is used for securing the admin CLI.

-v $CONFIG_DIR:/varnish_config/
	Mounts a directory with default.vcl file, which is a configuration file for varnish.

--link container_name:hostname
	Links another running container and assigns it a hostname. That hostname is used in varnish config to identify the container as a backend server

This container runs as root user.

# HISTORY
Similar to a Changelog of sorts which can be as detailed as the maintainer wishes.

# SEE ALSO
Github page for this container with detailed description: https://github.com/container-images/varnish