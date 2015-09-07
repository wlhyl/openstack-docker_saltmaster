include:
  - mysql
  - memcached
  - keystone
  - rabbitmq
  - glance-api
  - glance-registry
  - nova-api
  - nova-cert
  - nova-conductor
  - nova-consoleauth
  - nova-scheduler
  - nova-novncproxy
  - neutron-server

extend:
  keystone-mysql:
    mysql_database:
      - require:
        - docker: mysql
        - cmd: wait-mysql-port
  keystone:
    docker:
      - require:
        - docker: memcached
  glance-mysql:
    mysql_database:
      - require:
        - docker: mysql
        - cmd: wait-mysql-port
  glance-api:
    docker:
      - require:
        - docker: rabbitmq-premissions
  glance_service:
    keystone:
      - require:
        - cmd: wait-keystone-port
  glance-registry:
    docker:
      - require:
        - docker: glance-api
  nova-mysql:
    mysql_database:
      - require:
        - docker: mysql
        - cmd: wait-mysql-port
  nova_service:
    keystone:
      - require:
        - cmd: wait-keystone-port
  nova-api:
    docker:
      - require:
        - docker: glance-registry
  nova-cert:
    docker:
      - require:
        - docker: nova-api
  nova-conductor:
    docker:
      - require:
        - docker: nova-cert
  nova-consoleauth:
    docker:
      - require:
        - docker: nova-conductor
  nova-scheduler:
    docker:
      - require:
        - docker: nova-consoleauth
  nova-novncproxy:
    docker:
      - require:
        - docker: nova-scheduler
  neutron-mysql:
    mysql_database:
      - require:
        - docker: mysql
        - cmd: wait-mysql-port
  neutron-server:
    docker:
      - require:
        - docker: nova-scheduler
  neutron_service:
    keystone:
      - require:
        - cmd: wait-keystone-port

wait-mysql-port:
  cmd.run:
    - name: /bin/bash /tmp/wait-port.sh 300 {{ pillar["mysql"]["db_host"] }} 3306
    - stateful: True
    - require:
      - file: /tmp/wait-port.sh
      - docker: mysql