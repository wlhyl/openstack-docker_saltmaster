{{ pillar['docker']['registry'] }}/lzh/openstack-dashboard:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

openstack-dashboard:
  docker.running:
    - name: openstack-dashboard
    - image: {{ pillar['docker']['registry'] }}/lzh/openstack-dashboard:kilo
    - environment:
      - KEYSTONE_ENDPOINT: {{ pillar['keystone']['public_endpoint'] }}
      - OPENSTACK_KEYSTONE_DEFAULT_ROLE: user
      - MEMCACHE_SERVER: {{ pillar['keystone']['memcached_server'] }}
    - network_mode: host
    - volumes:
      - /opt/openstack/openstack-dashboard: /etc/openstack-dashboard
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/openstack-dashboard