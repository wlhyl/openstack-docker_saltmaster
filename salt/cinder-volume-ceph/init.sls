{% from "global/map.jinja" import openstack_version with context %}
{% from "global/map.jinja" import rbd_secret_uuid with context %}

{{ pillar['docker']['registry'] }}/lzh/cinder-volume:
  docker.pulled:
    - name: {{ pillar['docker']['registry'] }}/lzh/cinder-volume-ceph
    - tag: {{ openstack_version }}
    - insecure_registry: True
    - require_in:
      - docker: cinder-volume_docker

cinder-volume_docker:
  docker.running:
    - name: cinder-volume-ceph
    - image: {{ pillar['docker']['registry'] }}/lzh/cinder-volume-ceph:{{ openstack_version }}
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
      - RBD_SECRET_UUID: {{ rbd_secret_uuid }}
    - volumes:
      - /opt/openstack/cinder-volume-ceph/: /etc/cinder/
      - /opt/openstack/log/cinder-volume-ceph/: /var/log/cinder/c
      - /etc/ceph: /etc/ceph
    - network_mode: host