FROM koscicz/varnish-dummy

# Labels
LABEL name="Varnish" \
	summary="Varnish is an HTTP accelerator" \
	description="Varnish is an HTTP accelerator designed for content-heavy dynamic web sites." \
	version="1.0"


# Add configuration file
COPY files/default.vcl /etc/varnish/default.vcl

# Add secret file for varnishadm
COPY files/varnish_secret /etc/varnish_secret  

# Expose ports for varnish and it's admin CLI
EXPOSE 6801 6802

# Start varnish in the foreground
CMD /usr/sbin/varnishd -f /etc/varnish/default.vcl -a :6081 -T :6082 -s malloc,256M -S /etc/varnish_secret -F
