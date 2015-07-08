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
  require:
    - docker: {{ pillar['docker']['registry'] }}/lzh/keystone