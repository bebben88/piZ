#use latest armv7hf compatible raspbian OS version from group resin.io as base image
#FROM resin/armv7hf-debian:jessie
FROM resin/raspberry-pi-debian:latest
#enable building ARM container on x86 machinery on the web (comment out next line if built on Raspberry) 
#RUN [ "cross-build-start" ]

#labeling
LABEL maintainer="netpi@hilscher.com" \
      version="V1.1.0.0" \
      description="Debian with bluez protocol stack"

#version
ENV HILSCHERNETPI_BLUEZ_VERSION 1.1.0.0
ENV BLUEZ_VERSION 5.47 

#copy files
COPY "./init.d/*" /etc/init.d/

#install prerequisites
RUN apt-get update \
    && apt-get install -y openssh-server build-essential wget dbus \
       libical-dev libdbus-1-dev libglib2.0-dev libreadline-dev libudev-dev \
    && echo 'root:root' | chpasswd \
    && sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && mkdir /var/run/sshd

#get BCM chip firmware
RUN mkdir /etc/firmware \
    && curl -o /etc/firmware/BCM43430A1.hcd -L https://github.com/OpenELEC/misc-firmware/raw/master/firmware/brcm/BCM43430A1.hcd
#get bluez source
RUN wget -P /tmp/ https://www.kernel.org/pub/linux/bluetooth/bluez-${BLUEZ_VERSION}.tar.gz \
    && tar xf /tmp/bluez-${BLUEZ_VERSION}.tar.gz -C /tmp \
#compile bluez
    && cd /tmp/bluez-${BLUEZ_VERSION} \
    && ./configure --prefix=/usr \
       --mandir=/usr/share/man \
       --sysconfdir=/etc \
       --localstatedir=/var \
       --enable-library \
       --enable-experimental \
       --enable-maintainer-mode \
       --enable-deprecated \
    && make \
    && make install
#clean up
#    && rm -rf /tmp/* \
#    && apt-get remove wget \ 
#    && apt-get -yqq autoremove \
#    && apt-get -y clean \
#    && rm -rf /var/lib/apt/lists/*

#SSH port
EXPOSE 22

#do startscript
ENTRYPOINT ["/etc/init.d/entrypoint.sh"]

#set STOPSGINAL
STOPSIGNAL SIGTERM

#stop processing ARM emulation (comment out next line if built on Raspberry)
#RUN [ "cross-build-end" ]
