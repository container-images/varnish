FROM koscicz/varnish-dummy:latest

# Labels
LABEL summary="Varnish is an HTTP accelerator" \
	description="Varnish is an HTTP accelerator designed for content-heavy dynamic web sites." \
	version="5.0.0"

# Add configuration file
ADD files/default.vcl /etc/varnish/default.vcl

# Add secret file for varnishadm
ADD files/varnish_secret /etc/varnish_secret  

# Start varnish in the foreground
CMD /usr/sbin/varnishd -f /etc/varnish/default.vcl -a :6081 -T :6082 -s malloc,256M -S /etc/varnish_secret -F
