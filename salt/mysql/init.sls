{{ pillar['docker']['registry'] }}/lzh/mariadb:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

mysql:
  docker.running:
    - name: mysql
    - image: {{ pillar['docker']['registry'] }}/lzh/mariadb:kilo
    - environment:
      - MYSQL_ROOT_PASSWORD: {{ pillar['mysql']['root_password'] }}
    - volumes:
      - /opt/openstack/mysql/: /var/lib/mysql/
    - network_mode: host
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/mariadb