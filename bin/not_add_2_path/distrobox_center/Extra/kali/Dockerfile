FROM docker.io/kalilinux/kali-rolling:latest

RUN apt-get update && apt-get install -y ca-certificates 
RUN echo "deb http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware" | tee /etc/apt/sources.list
RUN apt-get update && apt-get install -y adduser
RUN adduser --disabled-password --gecos "" kali
RUN apt-get -y upgrade && apt-get install -y gtk3-nocsd sudo
RUN apt-get install -y xdg-user-dirs

RUN DEBIAN_FRONTEND=noninteractive apt-get install -yq kali-linux-large

USER kali
