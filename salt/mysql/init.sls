{{ pillar['docker']['registry'] }}/lzh/mariadb:
  docker.pulled:
    - tag: {{ pillar['mysql']['version'] }}
    - insecure_registry: True

mysql:
  docker.running:
    - name: mysql
    - image: {{ pillar['docker']['registry'] }}/lzh/mariadb:{{ pillar['mysql']['version'] }}
    - environment:
      - MYSQL_ROOT_PASSWORD: {{ pillar['mysql']['root_password'] }}
    - volumes:
      - /opt/openstack/mysql/: /var/lib/mysql/
    - network_mode: host
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/mariadb