FROM alpine

ARG __ControlPort=9051
ARG __DNSPort=5353
ARG __SocksPort=9050
ARG __TransPort=9040
ARG __GUID=4444
ARG __UUID=4444

RUN mkdir -p /var/lib/tor /etc/tor/run /var/log/tor
RUN addgroup -g $__GUID tor
RUN adduser -u $__UUID -G tor -s /bin/false -h /var/lib/tor -D tor

RUN chmod 750 /etc/tor
RUN chmod 700 /etc/tor/run

# Install tor
RUN apk --no-cache --no-progress upgrade
RUN apk --no-cache --no-progress add curl tini tor

RUN chown -Rh tor:tor /var/lib/tor /etc/tor /var/log/tor

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
#RUN echo 'User tor' >>/etc/tor/torrc

RUN rm -rf /tmp/*

COPY ContainerTorRunner.sh /usr/bin/
COPY ContainerTorChecker.sh /usr/bin/
RUN chmod 0755 /usr/bin/ContainerTorRunner.sh 
RUN chmod 0755 /usr/bin/ContainerTorChecker.sh

VOLUME ["/etc/tor", "/var/lib/tor"]

USER tor

HEALTHCHECK --interval=60s --timeout=15s --start-period=20s \
            CMD /usr/bin/ContainerTorChecker.sh

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/ContainerTorRunner.sh"]
