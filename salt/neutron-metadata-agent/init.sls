{% from "global/map.jinja" import region with context %}

{{ pillar['docker']['registry'] }}/lzh/neutron-metadata-agent:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

neutron-metadata-agent_docker:
  docker.running:
    - name: neutron-metadata-agent
    - image: {{ pillar['docker']['registry'] }}/lzh/neutron-metadata-agent:kilo
    - environment:
      - RABBIT_HOST: {{ pillar['neutron']['rabbit_host'] }}
      - RABBIT_USERID: {{ pillar['neutron']['rabbit_userid'] }}
      - RABBIT_PASSWORD: {{ pillar['neutron']['rabbit_password'] }}
      - KEYSTONE_INTERNAL_ENDPOINT: {{ pillar['keystone']['internal_endpoint'] }}
      - KEYSTONE_ADMIN_ENDPOINT: {{ pillar['keystone']['admin_endpoint'] }}
      - NEUTRON_PASS: {{ pillar['neutron']['neutron_pass'] }}
      - LOCAL_IP: {{ pillar[grains['id']]['local_ip'] }}
      - NOVA_METADATA_IP: {{ pillar['nova']['internal_endpoint'] }}
      - METADATA_PROXY_SHARED_SECRET: {{ pillar['neutron']['metadata_proxy_shared_secret'] }}
      - AUTH_REGION: {{ region }}
    - volumes:
      - /etc/neutron/: /etc/neutron/
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/neutron-metadata-agent

neutron-metadata-agent:
  pkg.installed:
    - fromrepo: jessie-backports
    - require_in:
      - docker: neutron-metadata-agent_docker
  service.running:
    - name: neutron-metadata-agent
    - require:
      - docker: neutron-metadata-agent_docker
    - watch:
      - docker: neutron-metadata-agent_docker