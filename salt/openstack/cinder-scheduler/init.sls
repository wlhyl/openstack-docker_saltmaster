{% from "global/map.jinja" import openstack_version with context %}

{{ pillar['docker']['registry'] }}/lzh/cinder-scheduler:
  docker.pulled:
    - tag: {{ openstack_version }}
    - insecure_registry: True

cinder-scheduler:
  docker.running:
    - name: cinder-scheduler
    - image: {{ pillar['docker']['registry'] }}/lzh/cinder-scheduler:{{ openstack_version }}
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
    - volumes:
      - /opt/openstack/cinder-scheduler/: /etc/cinder/
      - /opt/openstack/log/cinder-scheduler/: /var/log/cinder/
    - network_mode: host
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/cinder-scheduler