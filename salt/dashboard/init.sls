{{ pillar['docker']['registry'] }}/lzh/openstack-dashboard:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

openstack-dashboard:
  docker.running:
    - name: openstack-dashboard
    - image: {{ pillar['docker']['registry'] }}/lzh/openstack-dashboard:kilo
    - environment:
      - KEYSTONE_ENDPOINT: {{ pillar['keystone']['endpoint'] }}
      - OPENSTACK_KEYSTONE_DEFAULT_ROLE: user
    - ports:
        - "80/tcp":
               HostIp: ""
               HostPort: "80"
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/openstack-dashboard