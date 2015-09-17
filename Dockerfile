# image name lzh/salt-master
FROM debian:jessie

MAINTAINER Zuhui Liu penguin_tux@live.com

ENV BASE_VERSION 2015-07-27
ENV OPENSTACK_VERSION kilo


ENV DEBIAN_FRONTEND noninteractive

RUN echo "Asia/Shanghai" > /etc/timezone && \
	dpkg-reconfigure -f noninteractive tzdata

RUN echo "deb http://mirrors.aliyun.com/debian/ jessie main non-free contrib" > /etc/apt/sources.list
RUN echo "deb http://mirrors.aliyun.com/debian-security/ jessie/updates main non-free contrib" >> /etc/apt/sources.list
RUN echo "deb http://mirrors.aliyun.com/debian/ jessie-updates main non-free contrib" >> /etc/apt/sources.list
RUN echo "deb http://mirrors.aliyun.com/debian/ jessie-backports main non-free contrib" >> /etc/apt/sources.list

RUN apt-get update && apt-get dist-upgrade -y && apt-get install supervisor wget -y && apt-get clean

RUN wget -q -O- "http://debian.saltstack.com/debian-salt-team-joehealy.gpg.key" | apt-key add -
RUN echo deb http://debian.saltstack.com/debian jessie-saltstack main >> /etc/apt/sources.list

RUN apt-get update && apt-get dist-upgrade -y && apt-get install salt-master -y && apt-get clean

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

RUN cp -rp /etc/salt/ /
RUN rm -rf /etc/salt/*

RUN mkdir -p /srv/salt
RUN mkdir -p /srv/pillar
RUN mkdir -p /srv/custom/pillar

COPY salt/ /data/salt/
COPY pillar/ /data/pillar/

ADD salt-master.conf /etc/supervisor/conf.d/salt-master.conf
ADD pillarHttp.py /data/custom/pillar/pillarHttp.py
ADD entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

VOLUME ["/etc/salt/"]
VOLUME ["/srv/"]

EXPOSE 4505 4506

ENTRYPOINT ["/usr/bin/entrypoint.sh"]