FROM nginx

#########
# Note that apt-get update and apt-get install are executed in a single RUN instruction. 
# This is done to make sure that the latest packages will be installed. 
# If apt-get install were in a separate RUN instruction, then it would reuse a layer added by apt-get update, 
# which could had been created a long time ago.
#########

RUN apt-get update && apt-get install -y \
	software-properties-common && add-apt-repository "deb http://deb.debian.org/debian stretch-backports main" && \
	apt-get update && apt-get install -y \
	certbot python-certbot-nginx -t stretch-backports && \
    apt-get clean
