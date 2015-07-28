{% from "global/map.jinja" import openstack_profile with context %}

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
    - require_in:
      - docker: designate-pool-manager
    - connection_host: {{ pillar['mysql']['db_host'] }}
    - connection_user: root
    - connection_pass: "{{ pillar['mysql']['root_password'] }}"
    - connection_charset: utf8

{{ pillar['docker']['registry'] }}/lzh/designate-pool-manager:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

designate-pool-manager:
  docker.running:
    - name: designate-pool-manager
    - image: {{ pillar['docker']['registry'] }}/lzh/designate-pool-manager:kilo
    - environment:
      - DESIGNATE_DB: {{ pillar['designate']['db_host'] }}
      - DESIGNATE_DBPASS: {{ pillar['designate']['db_password'] }}
      - RABBIT_HOST: {{ pillar['designate']['rabbit_host'] }}
      - RABBIT_USERID: {{ pillar['designate']['rabbit_userid'] }}
      - RABBIT_PASSWORD: {{ pillar['designate']['rabbit_password'] }}
      - KEYSTONE_ENDPOINT: {{ pillar['keystone']['endpoint'] }}
      - DESIGNATE_PASS: {{ pillar['designate']['designate_pass'] }}
    - volumes:
      - /opt/openstack/designate-pool-manager/: /etc/designate
      - /opt/openstack/log/designate-pool-manager/: /var/log/designate/
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/designate-pool-manager