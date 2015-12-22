{% from "global/map.jinja" import openstack_version with context %}

{{ pillar['docker']['registry'] }}/lzh/glance-registry:
  docker.pulled:
    - tag: { openstack_version }
    - insecure_registry: True

glance-registry:
  docker.running:
    - name: glance-registry
    - image: {{ pillar['docker']['registry'] }}/lzh/glance-registry:{ openstack_version }
    - environment:
      - GLANCE_DB: {{ pillar['glance']['db_host'] }}
      - GLANCE_DBPASS: {{ pillar['glance']['db_password'] }}
      - KEYSTONE_INTERNAL_ENDPOINT: {{ pillar['keystone']['internal_endpoint'] }}
      - KEYSTONE_ADMIN_ENDPOINT: {{ pillar['keystone']['admin_endpoint'] }}
      - GLANCE_PASS: {{ pillar['glance']['glance_pass'] }}
    - volumes:
      - /opt/openstack/glance-registry/: /etc/glance/
      - /opt/openstack/log/glance-registry/: /var/log/glance/
    - network_mode: host
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/glance-registry