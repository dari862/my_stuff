FROM docker.io/kalilinux/kali-rolling:latest

RUN apt-get update -q --fix-missing && apt-get install -y ca-certificates 
RUN echo "deb http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware" | tee /etc/apt/sources.list
RUN apt-get update 
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq upgrade
RUN apt-get install -y gtk3-nocsd
RUN apt-get -y install sudo wget curl dbus-x11 xinit xdg-user-dirs zsh
RUN apt-get -y install locales && sed -i s/^#\ en_US.UTF-8\ UTF-8/en_US.UTF-8\ UTF-8/ /etc/locale.gen && locale-gen && update-locale LANG=en_US.UTF-8
RUN useradd -m -s /bin/zsh -G sudo kali
RUN echo "kali:kali" | chpasswd
USER kali
