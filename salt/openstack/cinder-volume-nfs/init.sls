{% from "openstack/global/map.jinja" import openstack_version with context %}

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
      - NFS_SERVER: {{ pillar[grains['id']]['nfs_server'] }}
    - volumes:
      - /opt/openstack/cinder-volume-nfs/: /etc/cinder/
      - /opt/openstack/log/cinder-volume-nfs/: /var/log/cinder/
    - network_mode: host