rabbitmq-image:
  docker.pulled:
    - name: rabbitmq
    - tag: 3.5.3
    - require_in:
      - docker: rabbitmq

rabbitmq:
  docker.running:
    - name: rabbitmq
    - image: rabbitmq:3.5.3
    - environment:
      - RABBITMQ_ERLANG_COOKIE: {{ pillar['rabbitmq']['rabbitmq_erlang_cookie'] }}
    - ports:
        - "5672/tcp":
               HostIp: ""
               HostPort: "5672"
        - "4369/tcp":
               HostIp: ""
               HostPort: "4369"
        - "25672/tcp":
               HostIp: ""
               HostPort: "25672"

/tmp/wait-port.sh:
  file.managed:
    - source: salt://keystone/files/wait-port.sh
    - template: jinja

wait-keystone-port:
  cmd.run:
    - name: /bin/bash /tmp/wait-port.sh 300 {{ pillar["rabbitmq"]["endpoint"] }} 5672
    - stateful: True
    - require:
      - file: /tmp/wait-port.sh
      - docker: rabbitmq
    - require_in:
      - docker: rabbitmq-user

rabbitmq-user:
  docker.run:
    - name: rabbitmqctl add_user {{ pillar['rabbitmq']['rabbitmq_user'] }} {{ pillar['rabbitmq']['rabbitmq_pass'] }}
    - cid: rabbitmq
    - docked_unless: docker exec rabbitmq list_users | grep {{ pillar['rabbitmq']['rabbitmq_user'] }}

rabbitmq-premissions
  docker.run:
    - name: rabbitmqctl set_permissions openstack ".*" ".*" ".*"
    - cid: rabbitmq
    - docked_unless: docker exec rabbitmq list_permissions | grep {{ pillar['rabbitmq']['rabbitmq_user'] }}
    - require:
      - docker: rabbitmq-user
