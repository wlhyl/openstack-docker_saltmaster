{% from "global/map.jinja" import openstack_profile with context %}

keystone-mysql:
  mysql_database.present:
    - name: keystone
    - connection_host: {{ pillar['mysql']['db_host'] }}
    - connection_user: root
    - connection_pass: "{{ pillar['mysql']['root_password'] }}"
    - connection_charset: utf8
  mysql_user.present:
    - host: "%"
    - name: keystone
    - password: "{{ pillar['keystone']['db_password'] }}"
    - require:
      - mysql_database: keystone-mysql
    - connection_host: {{ pillar['mysql']['db_host'] }}
    - connection_user: root
    - connection_pass: "{{ pillar['mysql']['root_password'] }}"
    - connection_charset: utf8
  mysql_grants.present:
    - grant: all
    - database: "keystone.*"
    - user: keystone
    - host: "%"
    - require_in:
      - docker: keystone
    - connection_host: {{ pillar['mysql']['db_host'] }}
    - connection_user: root
    - connection_pass: "{{ pillar['mysql']['root_password'] }}"
    - connection_charset: utf8


{{ pillar['docker']['registry'] }}/lzh/keystone:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

keystone:
  docker.running:
    - name: keystone
    - image: {{ pillar['docker']['registry'] }}/lzh/keystone:kilo
    - environment:
      - KEYSTONE_DB: {{ pillar['keystone']['db_host'] }}
      - KEYSTONE_DBPASS: {{ pillar['keystone']['db_password'] }}
      - ADMIN_TOKEN: {{ pillar['keystone']['admin_token'] }}
    - volumes:
      - /opt/openstack/keystone/: /etc/keystone/
      - /opt/openstack/log/keystone/: /var/log/keystone/
    - ports:
      - "5000/tcp":
              HostIp: ""
              HostPort: "5000"
      - "35357/tcp":
              HostIp: ""
              HostPort: "35357"
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/keystone

/tmp/wait-port.sh:
  file.managed:
    - source: salt://keystone/files/wait-port.sh
    - template: jinja

wait-keystone-port:
  cmd.run:
    - name: /bin/bash /tmp/wait-port.sh 30 {{ pillar["keystone"]["server"] }} 35357
    - stateful: True
    - require:
      - file: /tmp/wait-port.sh
      - docker: keystone
    - require_in:
      - keystone: Keystone_tenants
      - keystone: Keystone_roles
      - keystone: admin
      - keystone: keystone_service
      - keystone: keystone_endpoint

keystone_service:
  keystone.service_present:
    - name: keystone
    - service_type: identity
    - description: OpenStack Identity
    - profile: {{ openstack_profile }}

keystone_endpoint:
  keystone.endpoint_present:
    - name: keystone
    - publicurl: http://{{ pillar['keystone']['server'] }}:5000/v2.0
    - internalurl: http://{{ pillar['keystone']['server'] }}:5000/v2.0
    - adminurl: http://{{ pillar['keystone']['server'] }}:35357/v2.0
    - region: regionOne
    - profile: {{ openstack_profile }}
    - require:
      - keystone: keystone_service

Keystone_tenants:
  keystone.tenant_present:
    - names:
      - admin
      - service
    - description: "Admin Project"
    - profile: {{ openstack_profile }}
    - require:
      - keystone: keystone_endpoint

Keystone_roles:
  keystone.role_present:
    - names:
      - admin
    - profile: {{ openstack_profile }}
    - require:
      - keystone: keystone_endpoint

admin:
  keystone.user_present:
    - password: {{ pillar['keystone']['admin_pass'] }}
    - email: {{ pillar['keystone']['email'] }}
    - roles:
      - admin:   # tenants
        - admin  # roles
      - service:
        - admin
      - profile: {{ openstack_profile }}
    - require:
      - keystone: Keystone_tenants
      - keystone: Keystone_role