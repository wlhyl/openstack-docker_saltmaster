{% from "global/map.jinja" import openstack_version with context %}

{{ pillar['docker']['registry'] }}/lzh/cinder-volume-nfs:
  docker.pulled:
    - tag: {{ openstack_version }}
    - insecure_registry: True
    - require_in:
      - docker: cinder-volume-nfs_docker

cinder-volume-nfs_docker:
  docker.running:
    - name: cinder-volume-nfs
    - image: {{ pillar['docker']['registry'] }}/lzh/cinder-volume-nfs:{{ openstack_version }}
    - privileged: True
    - environment:
      - CINDER_DB: {{ pillar['cinder']['db_host'] }}
      - CINDER_DBPASS: {{ pillar['cinder']['db_password'] }}
      - RABBIT_HOST: {{ pillar['cinder']['rabbit_host'] }}
      - RABBIT_USERID: {{ pillar['cinder']['rabbit_userid'] }}
      - RABBIT_PASSWORD: {{ pillar['cinder']['rabbit_password'] }}
      - KEYSTONE_INTERNAL_ENDPOINT: {{ pillar['keystone']['internal_endpoint'] }}
      - KEYSTONE_ADMIN_ENDPOINT: {{ pillar['keystone']['admin_endpoint'] }}
      - MY_IP: {{ pillar[grains['id']]['my_ip'] }}
      - CINDER_PASS: {{ pillar['cinder']['cinder_pass'] }}
      - GLANCE_HOST: {{ pillar['glance']['internal_endpoint'] }}
      - VOLUME_BACKEND_NAME: {{ pillar[grains['id']]['volume_backend_name'] }}
    - volumes:
      - /etc/cinder/: /etc/cinder/

/etc/cinder/nfsshares:
  file.managed:
    - user: root
    - group: cinder
    - mode: 640
    - require:
      - docker: cinder-volume-nfs_docker
    - require_in:
      - service: cinder-volume

# liberty 未为jessie准备镜像
{% if grains['oscodename'] == 'jessie' %}
cinder-volume:
  pkg.installed:
    - pkgs:
      - cinder-volume 
      - python-mysqldb
      - nfs-common
    - fromrepo: jessie-backports
    - require_in:
      - docker: cinder-volume-nfs_docker
  service.running:
    - name: cinder-volume
    - enable: True
    - require:
      - docker: cinder-volume-nfs_docker
    - watch:
      - docker: cinder-volume-nfs_docker
      - file: /etc/cinder/nfsshares
{% endif %}

# liberty 未为trusty准备镜像
{% if grains['oscodename'] == 'trusty' %}
cinder-volume:
  pkg.installed:
    - pkgs:
      - cinder-volume 
      - python-mysqldb
      - nfs-common
    - require_in:
      - docker: cinder-volume-nfs_docker
  service.running:
    - name: cinder-volume
    - enable: True
    - require:
      - docker: cinder-volume-nfs_docker
    - watch:
      - docker: cinder-volume-nfs_docker
      - file: /etc/cinder/nfsshares
{% endif %}

{% if grains['os'] == 'CentOS' %}
cinder-volume:
  pkg.installed:
    - pkgs:
      - openstack-cinder
      - python-oslo-policy
      - nfs-utils
    - require_in:
      - docker: cinder-volume-nfs_docker
  service.running:
    - name: cinder-volume
    - enable: True
    - require:
      - docker: cinder-volume-nfs_docker
    - watch:
      - docker: cinder-volume-nfs_docker
      - file: /etc/cinder/nfsshares
{% endif %}