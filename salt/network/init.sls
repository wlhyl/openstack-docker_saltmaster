include:
  - neutron-plugin-openvswitch-agent
  - neutron-l3-agent
  - neutron-dhcp-agent
  - neutron-metadata-agent

extend：
  - {{ pillar['docker']['registry'] }}/lzh/neutron-l3-agent：
    docker:
      - require:
        - service: neutron-plugin-openvswitch-agent
  - {{ pillar['docker']['registry'] }}/lzh/neutron-dhcp-agent:
    docker:
      - require:
        - service: neutron-l3-agent
  - {{ pillar['docker']['registry'] }}/lzh/neutron-metadata-agent:
    docker:
      - require:
        - service: neutron-dhcp-agent