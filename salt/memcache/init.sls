memcache-image:
  docker.pulled:
    - name: memcache
    - tag: 1.4.24
    - require_in:
      - docker: memcache

memcache:
  docker.running:
    - name: memcache
    - image: memcache:1.4.24
    - network_mode: host