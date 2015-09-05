include:
  - nova-compute
  - neutron-plugin-openvswitch-agent
  
  
extend：
  - {{ pillar['docker']['registry'] }}/lzh/neutron-plugin-openvswitch-agent：
    docker:
      - require:
        - service: nova-compute