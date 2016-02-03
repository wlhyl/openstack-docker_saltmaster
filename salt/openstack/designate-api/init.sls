{% from "openstack/global/map.jinja" import openstack_profile with context %}
{% from "openstack/global/map.jinja" import region with context %}

designate-mysql:
  mysql_database.present:
    - name: designate
    - connection_host: {{ pillar['mysql']['db_host'] }}
    - connection_user: root
    - connection_pass: "{{ pillar['mysql']['root_password'] }}"
    - connection_charset: utf8
  mysql_user.present:
    - host: "%"
    - name: designate
    - password: "{{ pillar['designate']['db_password'] }}"
    - require:
      - mysql_database: designate-mysql
    - connection_host: {{ pillar['mysql']['db_host'] }}
    - connection_user: root
    - connection_pass: "{{ pillar['mysql']['root_password'] }}"
    - connection_charset: utf8
  mysql_grants.present:
    - grant: all
    - database: "designate.*"
    - user: designate
    - host: "%"
    - require:
      - mysql_user: designate-mysql
    - require_in:
      - docker: designate-api
    - connection_host: {{ pillar['mysql']['db_host'] }}
    - connection_user: root
    - connection_pass: "{{ pillar['mysql']['root_password'] }}"
    - connection_charset: utf8


{{ pillar['docker']['registry'] }}/lzh/designate-api:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

designate-api:
  docker.running:
    - name: designate-api
    - image: {{ pillar['docker']['registry'] }}/lzh/designate-api:kilo
    - environment:
      - DESIGNATE_DB: {{ pillar['designate']['db_host'] }}
      - DESIGNATE_DBPASS: {{ pillar['designate']['db_password'] }}
      - RABBIT_HOST: {{ pillar['designate']['rabbit_host'] }}
      - RABBIT_USERID: {{ pillar['designate']['rabbit_userid'] }}
      - RABBIT_PASSWORD: {{ pillar['designate']['rabbit_password'] }}
      - INTERNAL_ENDPOINT: {{ pillar['keystone']['internal_endpoint'] }}
      - ADMIN_ENDPOINT: {{ pillar['keystone']['admin_endpoint'] }}
      - DESIGNATE_PASS: {{ pillar['designate']['designate_pass'] }}
    - volumes:
      - /opt/openstack/designate-api/: /etc/designate
      - /opt/openstack/log/designate-api/: /var/log/designate/
    - network_mode: host
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/designate-api

/tmp/wait-port.sh:
  file.managed:
    - source: salt://openstack/keystone/files/wait-port.sh
    - template: jinja

wait-keystone-port:
  cmd.run:
    - name: /bin/bash /tmp/wait-port.sh 150 {{ pillar["keystone"]["admin_endpoint"] }} 35357
    - stateful: True
    - require:
      - file: /tmp/wait-port.sh
    - require_in:
      - keystone: designate_user
      - keystone: designate_service
      - keystone: designate_endpoint

designate_service:
  keystone.service_present:
    - name: designate
    - service_type: dns
    - description: Designate DNS Service
    - profile: {{ openstack_profile }}

designate_endpoint:
  keystone.endpoint_present:
    - name: designate
    - publicurl: http://{{ pillar['designate']['public_endpoint'] }}:9001/v1/
    - internalurl: http://{{ pillar['designate']['internal_endpoint'] }}:9001/v1/
    - adminurl: http://{{ pillar['designate']['admin_endpoint'] }}:9001/v1/
    - region: {{ region }}
    - profile: {{ openstack_profile }}
    - require:
      - keystone: designate_service

designate_user:
  keystone.user_present:
    - name: designate
    - password: "{{ pillar['designate']['designate_pass'] }}"
    - email: {{ pillar['designate']['email'] }}
    - roles:
        service:   # tenants
          - admin  # roles
    - profile: {{ openstack_profile }}