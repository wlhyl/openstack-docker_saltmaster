{% from "openstack/global/map.jinja" import openstack_profile with context %}
{% from "openstack/global/map.jinja" import openstack_version with context %}
{% from "openstack/global/map.jinja" import region with context %}

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
    - require:
      - mysql_user: keystone-mysql
    - require_in:
      - docker: keystone
    - connection_host: {{ pillar['mysql']['db_host'] }}
    - connection_user: root
    - connection_pass: "{{ pillar['mysql']['root_password'] }}"
    - connection_charset: utf8


{{ pillar['docker']['registry'] }}/lzh/keystone:
  docker.pulled:
    - tag: {{ openstack_version }}
    - insecure_registry: True

keystone:
  docker.running:
    - name: keystone
    - image: {{ pillar['docker']['registry'] }}/lzh/keystone:{{ openstack_version }}
    - environment:
      - KEYSTONE_DB: {{ pillar['keystone']['db_host'] }}
      - KEYSTONE_DBPASS: {{ pillar['keystone']['db_password'] }}
      - ADMIN_TOKEN: {{ pillar['keystone']['admin_token'] }}
      - MEMCACHE_SERVER: {{ pillar['keystone']['memcached_server'] }}
    - volumes:
      - /opt/openstack/keystone/: /etc/keystone/
      - /opt/openstack/log/keystone/: /var/log/keystone/
    - network_mode: host
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/keystone

/tmp/wait-port.sh:
  file.managed:
    - source: salt://openstack/keystone/files/wait-port.sh
    - template: jinja
#{% if grains['os'] == 'CentOS' %}
#nmap-ncat:
#  pkg.installed:
#    - require_in: 
#      - cmd: wait-keystone-port
#{% endif %}

wait-keystone-port:
  cmd.run:
    - name: /bin/bash /tmp/wait-port.sh 300 {{ pillar["keystone"]["admin_endpoint"] }} 35357
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
    - name: keystone{{ region }}
    - service_type: identity
    - description: OpenStack Identity
    - profile: {{ openstack_profile }}

keystone_endpoint:
  keystone.endpoint_present:
    - name: keystone{{ region }}
    - publicurl: http://{{ pillar['keystone']['public_endpoint'] }}:5000/v2.0
    - internalurl: http://{{ pillar['keystone']['internal_endpoint'] }}:5000/v2.0
    - adminurl: http://{{ pillar['keystone']['admin_endpoint'] }}:35357/v2.0
    - region: {{ region }}
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
    - password: "{{ pillar['keystone']['admin_pass'] }}"
    - email: {{ pillar['keystone']['email'] }}
    - roles:
        admin:   # tenants
          - admin  # roles
        # service:
        #   - admin
    - profile: {{ openstack_profile }}
    - require:
      - keystone: Keystone_tenants
      - keystone: Keystone_roles