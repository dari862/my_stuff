FROM debian:latest

# Setup demo environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=C.UTF-8 \
    DISPLAY=:0.0 \
    DISPLAY_WIDTH=1024 \
    DISPLAY_HEIGHT=768 

# Install dwm, supervisor, VNC, & X11 packages
RUN set -ex
RUN apt-get update
RUN apt-get install -y dwm novnc supervisor x11vnc xvfb pulseaudio pulseaudio-utils pavucontrol curl lsb-release

COPY app/. /app
RUN chmod +x /app/entrypoint.sh
RUN mv /app/index.html /usr/share/novnc/

RUN curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc
RUN echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc arch=$( dpkg --print-architecture )] https://repository.mullvad.net/deb/stable $(lsb_release -cs) main" | && \
	tee /etc/apt/sources.list.d/mullvad.list >/dev/null 2>&1
RUN apt-get update
RUN apt-get install -y mullvad-browser

RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

RUN useradd -m -g audio -s /bin/sh appuser

USER appuser

CMD ["/app/entrypoint.sh"]

# Set the workdir
WORKDIR /home/appuser

EXPOSE 4433
