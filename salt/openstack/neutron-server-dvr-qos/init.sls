{% from "openstack/global/map.jinja" import openstack_profile with context %}
{% from "openstack/global/map.jinja" import openstack_version with context %}
{% from "openstack/global/map.jinja" import region with context %}

neutron-mysql:
  mysql_database.present:
    - name: neutron
    - connection_host: {{ pillar['mysql']['db_host'] }}
    - connection_user: root
    - connection_pass: "{{ pillar['mysql']['root_password'] }}"
    - connection_charset: utf8
  mysql_user.present:
    - host: "%"
    - name: neutron
    - password: "{{ pillar['neutron']['db_password'] }}"
    - require:
      - mysql_database: neutron-mysql
    - connection_host: {{ pillar['mysql']['db_host'] }}
    - connection_user: root
    - connection_pass: "{{ pillar['mysql']['root_password'] }}"
    - connection_charset: utf8
  mysql_grants.present:
    - grant: all
    - database: "neutron.*"
    - user: neutron
    - host: "%"
    - require:
      - mysql_user: neutron-mysql
    - require_in:
      - docker: neutron-server
    - connection_host: {{ pillar['mysql']['db_host'] }}
    - connection_user: root
    - connection_pass: "{{ pillar['mysql']['root_password'] }}"
    - connection_charset: utf8


{{ pillar['docker']['registry'] }}/lzh/neutron-server:
  docker.pulled:
    - name: {{ pillar['docker']['registry'] }}/lzh/neutron-server-dvr-qos
    - tag: {{ openstack_version }}
    - insecure_registry: True

neutron-server:
  docker.running:
    - name: neutron-server-dvr-qos
    - image: {{ pillar['docker']['registry'] }}/lzh/neutron-server-dvr-qos:{{ openstack_version }}
    - environment:
      - NEUTRON_DB: {{ pillar['neutron']['db_host'] }}
      - NEUTRON_DBPASS: {{ pillar['neutron']['db_password'] }}
      - RABBIT_HOST: {{ pillar['neutron']['rabbit_host'] }}
      - RABBIT_USERID: {{ pillar['neutron']['rabbit_userid'] }}
      - RABBIT_PASSWORD: {{ pillar['neutron']['rabbit_password'] }}
      - KEYSTONE_INTERNAL_ENDPOINT: {{ pillar['keystone']['internal_endpoint'] }}
      - KEYSTONE_ADMIN_ENDPOINT: {{ pillar['keystone']['admin_endpoint'] }}
      - NEUTRON_PASS: {{ pillar['neutron']['neutron_pass'] }}
      - NOVA_PASS: {{ pillar['nova']['nova_pass'] }}
      - NOVA_URL: {{ pillar['nova']['internal_endpoint'] }}
      - REGION_NAME: {{ region }}
    - volumes:
      - /opt/openstack/neutron-server-dvr-qos/: /etc/neutron/
      - /opt/openstack/log/neutron-server-dvr-qos/: /var/log/neutron/
    - network_mode: host
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/neutron-server

neutron_service:
  keystone.service_present:
    - name: neutron{{ region }}
    - service_type: network
    - description: OpenStack Networking
    - profile: {{ openstack_profile }}

neutron_endpoint:
  keystone.endpoint_present:
    - name: neutron{{ region }}
    - publicurl: http://{{ pillar['neutron']['public_endpoint'] }}:9696
    - internalurl: http://{{ pillar['neutron']['internal_endpoint'] }}:9696
    - adminurl: http://{{ pillar['neutron']['admin_endpoint'] }}:9696
    - region: {{ region }}
    - profile: {{ openstack_profile }}
    - require:
      - keystone: neutron_service

neutron_user:
  keystone.user_present:
    - name: neutron
    - password: "{{ pillar['neutron']['neutron_pass'] }}"
    - email: {{ pillar['neutron']['email'] }}
    - roles:
        service:   # tenants
          - admin  # roles
    - profile: {{ openstack_profile }}