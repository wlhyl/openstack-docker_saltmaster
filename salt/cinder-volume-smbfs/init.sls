{% from "global/map.jinja" import openstack_version with context %}

{{ pillar['docker']['registry'] }}/lzh/cinder-volume-smbfs:
  docker.pulled:
    - tag: {{ openstack_version }}
    - insecure_registry: True
    - require_in:
      - docker: cinder-volume-smbfs_docker

cinder-volume-smbfs_docker:
  docker.running:
    - name: cinder-volume-smbfs
    - image: {{ pillar['docker']['registry'] }}/lzh/cinder-volume-smbfs:{{ openstack_version }}
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
      - SMBFS_SERVER: {{ pillar[grains['id']]['smbfs_server'] }}
      - SMB_PASS: {{ pillar[grains['id']]['smb_pass'] }}
    - volumes:
      - /opt/openstack/cinder-volume-smbfs/: /etc/cinder/
      - /opt/openstack/log/cinder-volume-smbfs/: /var/log/cinder/
    - network_mode: host