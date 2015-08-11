memcached-image:
  docker.pulled:
    - name: memcached
    - tag: 1.4.24
    - require_in:
      - docker: memcached

memcached:
  docker.running:
    - name: memcached
    - image: memcached:1.4.24
    - command: memcached -m 64
    - network_mode: host