{% from "openstack/global/map.jinja" import openstack_profile with context %}
{% from "openstack/global/map.jinja" import openstack_version with context %}
{% from "openstack/global/map.jinja" import region with context %}

nova-mysql:
  mysql_database.present:
    - name: nova
    - connection_host: {{ pillar['mysql']['db_host'] }}
    - connection_user: root
    - connection_pass: "{{ pillar['mysql']['root_password'] }}"
    - connection_charset: utf8
  mysql_user.present:
    - host: "%"
    - name: nova
    - password: "{{ pillar['nova']['db_password'] }}"
    - require:
      - mysql_database: nova-mysql
    - connection_host: {{ pillar['mysql']['db_host'] }}
    - connection_user: root
    - connection_pass: "{{ pillar['mysql']['root_password'] }}"
    - connection_charset: utf8
  mysql_grants.present:
    - grant: all
    - database: "nova.*"
    - user: nova
    - host: "%"
    - require:
      - mysql_user: nova-mysql
    - require_in:
      - docker: nova-api
    - connection_host: {{ pillar['mysql']['db_host'] }}
    - connection_user: root
    - connection_pass: "{{ pillar['mysql']['root_password'] }}"
    - connection_charset: utf8


{{ pillar['docker']['registry'] }}/lzh/nova-api:
  docker.pulled:
    - tag: {{ openstack_version }}
    - insecure_registry: True

nova-api:
  docker.running:
    - name: nova-api
    - image: {{ pillar['docker']['registry'] }}/lzh/nova-api:{{ openstack_version }}
    - privileged: True
    - environment:
      - NOVA_DB: {{ pillar['nova']['db_host'] }}
      - NOVA_DBPASS: {{ pillar['nova']['db_password'] }}
      - RABBIT_HOST: {{ pillar['nova']['rabbit_host'] }}
      - RABBIT_USERID: {{ pillar['nova']['rabbit_userid'] }}
      - RABBIT_PASSWORD: {{ pillar['nova']['rabbit_password'] }}
      - KEYSTONE_INTERNAL_ENDPOINT: {{ pillar['keystone']['internal_endpoint'] }}
      - KEYSTONE_ADMIN_ENDPOINT: {{ pillar['keystone']['admin_endpoint'] }}
      - MY_IP: {{ pillar[grains['id']]['my_ip'] }}
      - NOVA_PASS: {{ pillar['nova']['nova_pass'] }}
      - GLANCE_HOST: {{ pillar['glance']['internal_endpoint'] }}
      - NEUTRON_INTERNAL_ENDPOINT: {{ pillar['neutron']['internal_endpoint'] }}
      - NEUTRON_PASS: {{ pillar['neutron']['neutron_pass'] }}
      - METADATA_PROXY_SHARED_SECRET: {{ pillar['neutron']['metadata_proxy_shared_secret'] }}
      - REGION_NAME: {{ region }}
    - volumes:
      - /opt/openstack/nova-api/: /etc/nova
      - /opt/openstack/log/nova-api/: /var/log/nova/
    - network_mode: host
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/nova-api

nova_service:
  keystone.service_present:
    - name: nova
    - service_type: compute
    - description: OpenStack Compute
    - profile: {{ openstack_profile }}

nova_endpoint:
  keystone.endpoint_present:
    - name: nova
    - publicurl: http://{{ pillar['nova']['public_endpoint'] }}:8774/v2/%(tenant_id)s
    - internalurl: http://{{ pillar['nova']['internal_endpoint'] }}:8774/v2/%(tenant_id)s
    - adminurl: http://{{ pillar['nova']['admin_endpoint'] }}:8774/v2/%(tenant_id)s
    - region: {{ region }}
    - profile: {{ openstack_profile }}
    - require:
      - keystone: nova_service

nova_user:
  keystone.user_present:
    - name: nova
    - password: "{{ pillar['nova']['nova_pass'] }}"
    - email: {{ pillar['nova']['email'] }}
    - roles:
        service:   # tenants
          - admin  # roles
    - profile: {{ openstack_profile }}