{% from "global/map.jinja" import openstack_profile with context %}

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
    - tag: kilo
    - insecure_registry: True

nova-api:
  docker.running:
    - name: nova-api
    - image: {{ pillar['docker']['registry'] }}/lzh/nova-api:kilo
    - privileged: True
    - environment:
      - NOVA_DB: {{ pillar['nova']['db_host'] }}
      - NOVA_DBPASS: {{ pillar['nova']['db_password'] }}
      - RABBIT_HOST: {{ pillar['nova']['rabbit_host'] }}
      - RABBIT_USERID: {{ pillar['nova']['rabbit_userid'] }}
      - RABBIT_PASSWORD: {{ pillar['nova']['rabbit_password'] }}
      - KEYSTONE_ENDPOINT: {{ pillar['keystone']['endpoint'] }}
      - MY_IP: {{ pillar['nova']['my_ip'] }}
      - NOVA_PASS: {{ pillar['nova']['nova_pass'] }}
      - GLANCE_ENDPOINT: {{ pillar['glance']['endpoint'] }}
      - NEUTRON_ENDPOINT: {{ pillar['neutron']['endpoint'] }}
      - NEUTRON_PASS: {{ pillar['neutron']['neutron_pass'] }}
      - METADATA_PROXY_SHARED_SECRET: {{ pillar['neutron']['metadata_proxy_shared_secret'] }}
    - volumes:
      - /opt/openstack/nova-api/: /etc/nova
      - /opt/openstack/log/nova-api/: /var/log/nova/
    - ports:
      - "8774/tcp":
              HostIp: ""
              HostPort: "8774"
      - "8775/tcp":
              HostIp: ""
              HostPort: "8775"
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/nova-api

/tmp/wait-port.sh:
  file.managed:
    - source: salt://keystone/files/wait-port.sh
    - template: jinja

wait-keystone-port:
  cmd.run:
    - name: /bin/bash /tmp/wait-port.sh 150 {{ pillar["keystone"]["server"] }} 35357
    - stateful: True
    - require:
      - file: /tmp/wait-port.sh
    - require_in:
      - keystone: nova_user
      - keystone: nova_service
      - keystone: nova_endpoint

nova_service:
  keystone.service_present:
    - name: nova
    - service_type: compute
    - description: OpenStack Compute
    - profile: {{ openstack_profile }}

nova_endpoint:
  keystone.endpoint_present:
    - name: nova
    - publicurl: http://{{ pillar['nova']['endpoint'] }}:8774/v2/%(tenant_id)s
    - internalurl: http://{{ pillar['nova']['endpoint'] }}:8774/v2/%(tenant_id)s
    - adminurl: http://{{ pillar['nova']['endpoint'] }}:8774/v2/%(tenant_id)s
    - region: regionOne
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