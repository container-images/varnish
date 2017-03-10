FROM fedora:25

LABEL summary="Varnish is an HTTP accelerator." \
	description="Varnish is an HTTP accelerator designed for content-heavy dynamic web sites." \
	version="5.0.0"

RUN dnf install -y --setopt=tsflags=nodocs varnish  && dnf -y clean all