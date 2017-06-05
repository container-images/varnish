FROM baseruntime/baseruntime:latest

# Image metadata
ENV NAME=varnish \
    VARNISH_VERSION=5.0.0 \
    VERSION=0 \
    RELEASE=1 \
    ARCH=x86_64

# Labels
LABEL com.redhat.component="$NAME" \
    name="$FGC/$NAME" \
	summary="Varnish is an HTTP accelerator" \
	description="Varnish is an HTTP accelerator designed for content-heavy dynamic web sites." \
	version="$VERSION" \
	release="$RELEASE.$DISTTAG" \
	architecture="$ARCH" \
	usage="docker run -p <PORT>:6081 -p <MANAGEMENT_PORT>:6082" \
	io.k8s.description="Varnish is an HTTP accelerator designed for content-heavy dynamic web sites." \
	io.k8s.display-name="Varnish" \
	io.openshift.expose-services="6801:http" \
	io.openshift.tags="http,proxy,varnish,varnish5" 

COPY files/varnish.repo /etc/yum.repos.d/

#install varnish
RUN microdnf --nodocs --enablerepo varnish install -y varnish && \
    microdnf clean all

# Add configuration file
COPY files/default.vcl /etc/varnish/default.vcl

# Add secret file for varnishadm
COPY files/varnish_secret /etc/varnish_secret  

# Copy help file
COPY root/help.1 /help.1

# Expose ports for varnish and it's admin CLI
EXPOSE 6801 6802

# Start varnish in the foreground
CMD /usr/sbin/varnishd -f /etc/varnish/default.vcl -a :6081 -T :6082 -s malloc,256M -S /etc/varnish_secret -F
