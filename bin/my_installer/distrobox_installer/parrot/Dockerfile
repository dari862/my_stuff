FROM docker.io/parrotsec/core:latest

RUN apt-get update -q --fix-missing && apt-get install -y ca-certificates 
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq upgrade 
RUN apt-get install -y gtk3-nocsd
RUN apt-get -y install locales && sed -i s/^#\ en_US.UTF-8\ UTF-8/en_US.UTF-8\ UTF-8/ /etc/locale.gen && locale-gen && update-locale LANG=en_US.UTF-8

RUN DEBIAN_FRONTEND=noninteractive apt-get install -yq parrot-tools-full
