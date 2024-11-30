FROM docker.io/parrotsec/core:latest

RUN apt-get update && apt-get install -y ca-certificates 
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq upgrade 
RUN apt-get install -y gtk3-nocsd 

RUN DEBIAN_FRONTEND=noninteractive apt-get install -yq parrot-tools-full
