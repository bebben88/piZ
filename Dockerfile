FROM hypriot/rpi-node:6

# add support for gpio library
RUN apt-get update
RUN apt-get install python-rpi.gpio

# Home directory for Node-RED application source code.
RUN mkdir -p /usr/src/node-red

# User data directory, contains flows, config and nodes.
RUN mkdir /data

WORKDIR /usr/src/node-red

# Add the package verification key
RUN apt-get update \
	&& apt-get upgrade \
	&& apt-get install -y wget git supervisor \
	&& mkdir -p /var/log/supervisor

COPY Makefile.PATCHED /tmp/Makefile.PATCHED

# compile libmicrohttpd / open-zwave and open-zwave-panel
RUN apt-get install -y build-essential libudev-dev libmicrohttpd-dev libgnutls28-dev \
	&& wget ftp://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-0.9.19.tar.gz \
	&& tar zxvf libmicrohttpd-0.9.19.tar.gz && mv libmicrohttpd-0.9.19 libmicrohttpd && rm libmicrohttpd-0.9.19.tar.gz \
	&& cd libmicrohttpd && ./configure && make && make install \
	&& ldconfig \
	&& cd /opt \
	&& git clone https://github.com/OpenZWave/open-zwave.git open-zwave \
	&& cd open-zwave && make \
	&& cd /opt \
	&& git clone https://github.com/OpenZwave/open-zwave-control-panel open-zwave-control-panel \
	&& cd open-zwave-control-panel \
	&& ln -sd ../open-zwave/config \
	&& mv /tmp/Makefile.PATCHED Makefile \
	&& make \
	&& apt-get purge build-essential libudev-dev libmicrohttpd-dev libgnutls28-dev

COPY supervisor/supervisor_main.conf /etc/supervisor/conf.d/main.conf
COPY supervisor/open-zwave-panel.conf /etc/supervisor/conf.d/open-zwave-panel.conf

# Add node-red user so we aren't running as root.
RUN useradd --home-dir /usr/src/node-red --no-create-home node-red \
    && chown -R node-red:node-red /data \
    && chown -R node-red:node-red /usr/src/node-red

USER node-red

# package.json contains Node-RED NPM module and node dependencies
COPY package.json /usr/src/node-red/
RUN npm install

# User configuration directory volume
EXPOSE 1880

# Environment variable holding file path for flows configuration
ENV FLOWS=flows.json
ENV NODE_PATH=/usr/src/node-red/node_modules:/data/node_modules

CMD ["npm", "start", "--", "--userDir", "/data"]