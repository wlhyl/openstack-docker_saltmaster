{% from "global/map.jinja" import openstack_profile with context %}
{% from "global/map.jinja" import openstack_version with context %}
{% from "global/map.jinja" import region with context %}

glance-mysql:
  mysql_database.present:
    - name: glance
    - connection_host: {{ pillar['mysql']['db_host'] }}
    - connection_user: root
    - connection_pass: "{{ pillar['mysql']['root_password'] }}"
    - connection_charset: utf8
  mysql_user.present:
    - host: "%"
    - name: glance
    - password: "{{ pillar['glance']['db_password'] }}"
    - require:
      - mysql_database: glance-mysql
    - connection_host: {{ pillar['mysql']['db_host'] }}
    - connection_user: root
    - connection_pass: "{{ pillar['mysql']['root_password'] }}"
    - connection_charset: utf8
  mysql_grants.present:
    - grant: all
    - database: "glance.*"
    - user: glance
    - host: "%"
    - require:
      - mysql_user: glance-mysql
    - require_in:
      - docker: glance-api
    - connection_host: {{ pillar['mysql']['db_host'] }}
    - connection_user: root
    - connection_pass: "{{ pillar['mysql']['root_password'] }}"
    - connection_charset: utf8


{{ pillar['docker']['registry'] }}/lzh/glance-api:
  docker.pulled:
    - name: {{ pillar['docker']['registry'] }}/lzh/glance-api-ceph
    - tag: {{ openstack_version }}
    - insecure_registry: True

glance-api:
  docker.running:
    - name: glance-api-ceph
    - image: {{ pillar['docker']['registry'] }}/lzh/glance-api-ceph:{{ openstack_version }}
    - environment:
      - GLANCE_DB: {{ pillar['glance']['db_host'] }}
      - GLANCE_DBPASS: {{ pillar['glance']['db_password'] }}
      - KEYSTONE_INTERNAL_ENDPOINT: {{ pillar['keystone']['internal_endpoint'] }}
      - KEYSTONE_ADMIN_ENDPOINT: {{ pillar['keystone']['admin_endpoint'] }}
      - GLANCE_PASS: {{ pillar['glance']['glance_pass'] }}
    - volumes:
      - /opt/openstack/glance-api-ceph/: /etc/glance/
      - /opt/openstack/log/glance-api-ceph/: /var/log/glance/
      - /etc/ceph: /etc/ceph
    - network_mode: host
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/glance-api

glance_service:
  keystone.service_present:
    - name: glance
    - service_type: image
    - description: OpenStack Image service
    - profile: {{ openstack_profile }}

glance_endpoint:
  keystone.endpoint_present:
    - name: glance
    - publicurl: http://{{ pillar['glance']['public_endpoint'] }}:9292
    - internalurl: http://{{ pillar['glance']['internal_endpoint'] }}:9292
    - adminurl: http://{{ pillar['glance']['admin_endpoint'] }}:9292
    - region: {{ region }}
    - profile: {{ openstack_profile }}
    - require:
      - keystone: glance_service

glance_user:
  keystone.user_present:
    - name: glance
    - password: "{{ pillar['glance']['glance_pass'] }}"
    - email: {{ pillar['glance']['email'] }}
    - roles:
        service:   # tenants
          - admin  # roles
    - profile: {{ openstack_profile }}