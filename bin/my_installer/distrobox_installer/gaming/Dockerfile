FROM docker.io/archlinux/archlinux:latest

RUN mkdir -p /tmp/$USER/gaming_converter
COPY gaming_converter /tmp/$USER/gaming_converter/gaming_converter
COPY /tmp/$USER/ENV /tmp/$USER/gaming_converter/ENV
RUN cd /tmp/$USER/gaming_converter/ENV && \
	source ./ENV && \
	chmod 0755 gaming_converter && \
	./gaming_converter && \
	cd / && rm -rdf /tmp/$USER/gaming_converter
