# A docker file just to make a docker of the ldap-utils
# Just do:
#   docker run -it this-docker-file /bin/bash
# and you have a shell with the ldap-utils without having to install them
FROM debian:stable-slim
RUN apt-get update
RUN apt-get install -y ldap-utils
