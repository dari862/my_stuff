FROM debian:latest

# Setup demo environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=C.UTF-8 \
    DISPLAY=:0.0 \
    DISPLAY_WIDTH=1024 \
    DISPLAY_HEIGHT=768 

ARG app
ENV app ${app}

# Install dwm, supervisor, VNC, & X11 packages
RUN set -ex
RUN apt-get update
RUN apt-get install -y dwm novnc supervisor x11vnc xvfb pulseaudio pavucontrol

COPY app/. /app

RUN mv /app/index.html /usr/share/novnc/
RUN mv /app/create_conf /tmp
RUN mv /app/run_script /tmp

RUN [ "$app" = "firefox" ] && apt-get install -y firefox-esr || :

RUN /tmp/create_conf "$app"

RUN [ "$app" = "mullvad" ] && apt-get install -y mullvad-browser

RUN /tmp/create_conf "$app"

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

RUN useradd -ms /bin/sh appuser

USER appuser

CMD ["/app/entrypoint.sh"]

# Set the workdir
WORKDIR /home/appuser

EXPOSE 8080
