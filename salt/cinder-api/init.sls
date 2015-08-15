{% from "global/map.jinja" import openstack_profile with context %}
{% from "global/map.jinja" import region with context %}

cinder-mysql:
  mysql_database.present:
    - name: cinder
    - connection_host: {{ pillar['mysql']['db_host'] }}
    - connection_user: root
    - connection_pass: "{{ pillar['mysql']['root_password'] }}"
    - connection_charset: utf8
  mysql_user.present:
    - host: "%"
    - name: cinder
    - password: "{{ pillar['cinder']['db_password'] }}"
    - require:
      - mysql_database: cinder-mysql
    - connection_host: {{ pillar['mysql']['db_host'] }}
    - connection_user: root
    - connection_pass: "{{ pillar['mysql']['root_password'] }}"
    - connection_charset: utf8
  mysql_grants.present:
    - grant: all
    - database: "cinder.*"
    - user: cinder
    - host: "%"
    - require:
      - mysql_user: cinder-mysql
    - require_in:
      - docker: cinder-api
    - connection_host: {{ pillar['mysql']['db_host'] }}
    - connection_user: root
    - connection_pass: "{{ pillar['mysql']['root_password'] }}"
    - connection_charset: utf8


{{ pillar['docker']['registry'] }}/lzh/cinder-api:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

cinder-api:
  docker.running:
    - name: cinder-api
    - image: {{ pillar['docker']['registry'] }}/lzh/cinder-api:kilo
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
      - /opt/openstack/cinder-api/: /etc/cinder/
      - /opt/openstack/log/cinder-api/: /var/log/cinder/
    - network_mode: host
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/cinder-api

/tmp/wait-port.sh:
  file.managed:
    - source: salt://keystone/files/wait-port.sh
    - template: jinja

wait-keystone-port:
  cmd.run:
    - name: /bin/bash /tmp/wait-port.sh 150 {{ pillar["keystone"]["admin_endpoint"] }} 35357
    - stateful: True
    - require:
      - file: /tmp/wait-port.sh
    - require_in:
      - keystone: cinder_user
      - keystone: cinder_service
      - keystone: cinderv2_service
      - keystone: cinder_endpoint
      - keystone: cinderv2_endpoint

cinder_service:
  keystone.service_present:
    - name: cinder
    - service_type: volume
    - description: OpenStack Block Storage
    - profile: {{ openstack_profile }}

cinder_endpoint:
  keystone.endpoint_present:
    - name: cinder
    - publicurl: http://{{ pillar['cinder']['public_endpoint'] }}:8776/v2/%(tenant_id)s
    - internalurl: http://{{ pillar['cinder']['internal_endpoint'] }}:8776/v2/%(tenant_id)s
    - adminurl: http://{{ pillar['cinder']['admin_endpoint'] }}:8776/v2/%(tenant_id)s
    - region: {{ region }}
    - profile: {{ openstack_profile }}
    - require:
      - keystone: cinder_service

cinderv2_service:
  keystone.service_present:
    - name: cinderv2
    - service_type: volumev2
    - description: OpenStack Block Storage
    - profile: {{ openstack_profile }}

cinderv2_endpoint:
  keystone.endpoint_present:
    - name: cinderv2
    - publicurl: http://{{ pillar['cinder']['public_endpoint'] }}:8776/v2/%(tenant_id)s
    - internalurl: http://{{ pillar['cinder']['internal_endpoint'] }}:8776/v2/%(tenant_id)s
    - adminurl: http://{{ pillar['cinder']['admin_endpoint'] }}:8776/v2/%(tenant_id)s
    - region: regionOne
    - profile: {{ openstack_profile }}
    - require:
      - keystone: cinderv2_service

cinder_user:
  keystone.user_present:
    - name: cinder
    - password: "{{ pillar['cinder']['cinder_pass'] }}"
    - email: {{ pillar['cinder']['email'] }}
    - roles:
        service:   # tenants
          - admin  # roles
    - profile: {{ openstack_profile }}