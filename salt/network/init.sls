include:
  - repo
  - neutron-plugin-openvswitch-agent
  - neutron-l3-agent

extend:
  {{ pillar['docker']['registry'] }}/lzh/neutron-l3-agent:
    docker:
      - require:
        - service: neutron-plugin-openvswitch-agent

{% if grains['oscodename'] == 'trusty' %}
  cloud-archive:
    pkgrepo:
      - require_in:
        - pkg: neutron-plugin-openvswitch-agent
{% endif %}