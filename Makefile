.PHONY: build run default

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

default: run

build:
	docker build --tag=$(IMAGE_NAME) .

run: build
	docker run $(FLAGS) -p $(PORT):6081 -p $(MANAGEMENT_PORT):6082 $(foreach link,$(LINK), --link $(link) )  $(IMAGE_NAME)
