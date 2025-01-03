FROM alpine

ARG __ControlPort
ARG __DNSPort
ARG __SocksPort
ARG __TransPort
ARG __GUID
ARG __UUID
ARG _TOR_USER

RUN mkdir -p /var/lib/tor /etc/tor/run /var/log/tor
RUN addgroup -g $__GUID $_TOR_USER
RUN adduser -u $__UUID -G $_TOR_USER -s /bin/false -h /var/lib/tor -D $_TOR_USER

RUN chmod 750 /etc/tor
RUN chmod 700 /etc/tor/run

# Install tor
RUN apk --no-cache --no-progress upgrade
RUN apk --no-cache --no-progress add curl tini tor

RUN chown -Rh $_TOR_USER:$_TOR_USER /var/lib/tor /etc/tor /var/log/tor

# configure tor
RUN echo "AutomapHostsOnResolve 1" >>/etc/tor/torrc && \
    echo "ControlPort $__ControlPort" >>/etc/tor/torrc && \
    echo "ControlSocket /etc/tor/run/control" >>/etc/tor/torrc && \
    echo "ControlSocketsGroupWritable 1" >>/etc/tor/torrc && \
    echo "CookieAuthentication 1" >>/etc/tor/torrc && \
    echo "CookieAuthFile /etc/tor/run/control.authcookie" >>/etc/tor/torrc && \
    echo "CookieAuthFileGroupReadable 1" >>/etc/tor/torrc && \
    echo "DNSPort $__DNSPort" >>/etc/tor/torrc && \
    echo "DataDirectory /var/lib/tor" >>/etc/tor/torrc && \
    echo "ExitPolicy reject *:*" >>/etc/tor/torrc && \
    echo "Log notice stderr" >>/etc/tor/torrc && \
    echo "RunAsDaemon 0" >>/etc/tor/torrc && \
    echo "SocksPort $__SocksPort IsolateDestAddr" >>/etc/tor/torrc && \
    echo "TransPort $__TransPort" >>/etc/tor/torrc && \
    echo "VirtualAddrNetworkIPv4 10.192.0.0/10" >>/etc/tor/torrc
#RUN echo "User $_TOR_USER" >>/etc/tor/torrc

RUN rm -rf /tmp/*

COPY ContainerChecker.sh /usr/bin/
COPY start-service.sh /usr/bin/

RUN chmod 0755 /usr/bin/start-service.sh
RUN chmod 0755 /usr/bin/ContainerChecker.sh

VOLUME ["/etc/tor", "/var/lib/tor"]

USER $_TOR_USER

HEALTHCHECK --interval=60s --timeout=15s --start-period=20s \
            CMD /usr/bin/ContainerChecker.sh

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/start-service.sh"]
