include:
  - repo
  - nova-compute
  - neutron-plugin-openvswitch-agent
  
  
extend:
  {{ pillar['docker']['registry'] }}/lzh/neutron-plugin-openvswitch-agent:
    docker:
      - require:
        - service: nova-compute
{% if grains['oscodename'] == 'trusty' %}
  cloud-archive:
    pkgrepo:
      - require_in:
        - pkg: nova-compute
{% endif %}