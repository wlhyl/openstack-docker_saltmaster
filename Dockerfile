# image name lzh/salt-master
FROM 10.64.0.50:5000/lzh/openstackbase:kilo

MAINTAINER Zuhui Liu penguin_tux@live.com

ENV BASE_VERSION 2015-07-07
ENV OPENSTACK_VERSION kilo


ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install wget -y
RUN apt-get clean

RUN wget -q -O- "http://debian.saltstack.com/debian-salt-team-joehealy.gpg.key" | apt-key add -
RUN echo deb http://debian.saltstack.com/debian jessie-saltstack main >> /etc/apt/sources.list

RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install salt-master -y
RUN apt-get clean

RUN env --unset=DEBIAN_FRONTEND

RUN sed -i /#interface/s/^#//g /etc/salt/master

RUN echo extension_modules: /srv/custom >> /etc/salt/master

RUN echo file_roots: >> /etc/salt/master
RUN echo \ \ base: >> /etc/salt/master
RUN echo \ \ \ \ - /srv/salt >> /etc/salt/master

RUN echo pillar_roots: >> /etc/salt/master
RUN echo \ \ base: >> /etc/salt/master
RUN echo \ \ \ \ - /srv/pillar >> /etc/salt/master

RUN echo ext_pillar: >> /etc/salt/master
RUN echo \ \ - pillarHttp: http://127.0.0.1:8000/api/ >> /etc/salt/master

RUN mkdir -p /srv/salt
RUN mkdir -p /srv/pillar
RUN mkdir -p /srv/custom/pillar

ADD salt-master.conf /etc/supervisor/conf.d/salt-master.conf
ADD pillarHttp.py /srv/custom/pillar/pillarHttp.py
ADD entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

EXPOSE 4505 4506

ENTRYPOINT ["/usr/bin/entrypoint.sh"]