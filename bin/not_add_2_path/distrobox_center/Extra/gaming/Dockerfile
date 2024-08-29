FROM docker.io/archlinux/archlinux:latest

RUN mkdir -p /tmp/gaming_converter
COPY gaming_converter /tmp/gaming_converter/gaming_converter
COPY /tmp/ENV /tmp/gaming_converter/ENV
RUN cd /tmp/gaming_converter/ENV && \
	source ./ENV && \
	chmod 0755 gaming_converter && \
	./gaming_converter && \
	cd / && rm -rdf /tmp/gaming_converter
