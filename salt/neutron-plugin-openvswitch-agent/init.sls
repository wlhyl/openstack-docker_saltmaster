{{ pillar['docker']['registry'] }}/lzh/neutron-plugin-openvswitch-agent:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

neutron-plugin-openvswitch-agent_docker:
  docker.running:
    - name: neutron-plugin-openvswitch-agent
    - image: {{ pillar['docker']['registry'] }}/lzh/neutron-plugin-openvswitch-agent:kilo
    - environment:
      - RABBIT_HOST: {{ pillar['neutron']['rabbit_host'] }}
      - RABBIT_USERID: {{ pillar['neutron']['rabbit_userid'] }}
      - RABBIT_PASSWORD: {{ pillar['neutron']['rabbit_password'] }}
      - KEYSTONE_ENDPOINT: {{ pillar['keystone']['endpoint'] }}
      - NEUTRON_PASS: {{ pillar['neutron']['neutron_pass'] }}
      - LOCAL_IP: {{ pillar[grains['id']]['local_ip'] }}
    - volumes:
      - /etc/neutron/: /etc/neutron/
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/neutron-plugin-openvswitch-agent

neutron-plugin-openvswitch-agent:
  pkg.installed:
    - require_in:
      - docker: neutron-plugin-openvswitch-agent_docker
  service.running:
    - require:
      - docker: neutron-plugin-openvswitch-agent_docker
    - watch:
      - docker: neutron-plugin-openvswitch-agent_docker