memcached-image:
  docker.pulled:
    - name: memcached
    - tag: 1.4.24
    - require_in:
      - docker: memcache

memcached:
  docker.running:
    - name: memcached
    - image: memcached:1.4.24
    - network_mode: host