{{ pillar['docker']['registry'] }}/lzh/neutron-l3-agent:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

neutron-l3-agent_docker:
  docker.running:
    - name: neutron-l3-agent
    - image: {{ pillar['docker']['registry'] }}/lzh/neutron-l3-agent:kilo
    - environment:
      - RABBIT_HOST: {{ pillar['neutron']['rabbit_host'] }}
      - RABBIT_USERID: {{ pillar['neutron']['rabbit_userid'] }}
      - RABBIT_PASSWORD: {{ pillar['neutron']['rabbit_password'] }}
      - KEYSTONE_INTERNAL_ENDPOINT: {{ pillar['keystone']['internal_endpoint'] }}
      - KEYSTONE_ADMIN_ENDPOINT: {{ pillar['keystone']['admin_endpoint'] }}
      - NEUTRON_PASS: {{ pillar['neutron']['neutron_pass'] }}
      - LOCAL_IP: {{ pillar[grains['id']]['local_ip'] }}
    - volumes:
      - /etc/neutron/: /etc/neutron/
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/neutron-l3-agent

neutron-l3-agent:
  pkg.installed:
    - fromrepo: jessie-backports
    - require_in:
      - docker: neutron-l3-agent_docker
  service.running:
    - name: neutron-l3-agent
    - require:
      - docker: neutron-l3-agent_docker
    - watch:
      - docker: neutron-l3-agent_docker