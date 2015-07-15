{% from "global/map.jinja" import openstack_profile with context %}

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
    - require_in:
      - docker: neutron-server
    - connection_host: {{ pillar['mysql']['db_host'] }}
    - connection_user: root
    - connection_pass: "{{ pillar['mysql']['root_password'] }}"
    - connection_charset: utf8


{{ pillar['docker']['registry'] }}/lzh/neutron-server:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

neutron-server:
  docker.running:
    - name: neutron-server
    - image: {{ pillar['docker']['registry'] }}/lzh/neutron-server:kilo
    - privileged: True
    - environment:
      - NEUTRON_DB: {{ pillar['neutron']['db_host'] }}
      - NEUTRON_DBPASS: {{ pillar['neutron']['db_password'] }}
      - RABBIT_HOST: {{ pillar['neutron']['rabbit_host'] }}
      - RABBIT_USERID: {{ pillar['neutron']['rabbit_userid'] }}
      - RABBIT_PASSWORD: {{ pillar['neutron']['rabbit_password'] }}
      - KEYSTONE_ENDPOINT: {{ pillar['keystone']['endpoint'] }}
      - NEUTRON_PASS: {{ pillar['neutron']['neutron_pass'] }}
      - NOVA_PASS: {{ pillar['nova']['nova_pass'] }}
      - NOVA_URL: {{ pillar['nova']['endpoint'] }}
    - volumes:
      - /opt/openstack/neutron-server/: /etc/neutron/
      - /opt/openstack/log/neutron-server/: /var/log/neutron/
    - ports:
      - "9696/tcp":
              HostIp: ""
              HostPort: "9696"
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/neutron-server

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
      - keystone: neutron_user
      - keystone: neutron_service
      - keystone: neutron_endpoint

neutron_service:
  keystone.service_present:
    - name: neutron
    - service_type: network
    - description: OpenStack Networking
    - profile: {{ openstack_profile }}

neutron_endpoint:
  keystone.endpoint_present:
    - name: neutron
    - publicurl: http://{{ pillar['neutron']['endpoint'] }}:9696
    - internalurl: http://{{ pillar['neutron']['endpoint'] }}:9696
    - adminurl: http://{{ pillar['neutron']['endpoint'] }}:9696
    - region: regionOne
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