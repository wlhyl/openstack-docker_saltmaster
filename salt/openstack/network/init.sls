include:
  - repo
  - neutron-plugin-openvswitch-agent
  - neutron-l3-agent
  - neutron-dhcp-agent
  - neutron-metadata-agent
  - neutron-ovs-cleanup

extend:
  {{ pillar['docker']['registry'] }}/lzh/neutron-l3-agent:
    docker:
      - require:
        - service: neutron-plugin-openvswitch-agent
  {{ pillar['docker']['registry'] }}/lzh/neutron-dhcp-agent:
    docker:
      - require:
        - service: neutron-l3-agent
  {{ pillar['docker']['registry'] }}/lzh/neutron-metadata-agent:
    docker:
      - require:
        - service: neutron-dhcp-agent
{% if grains['oscodename'] == 'trusty' %}
  cloud-archive:
    pkgrepo:
      - require_in:
        - pkg: neutron-plugin-openvswitch-agent
{% endif %}
{% if grains['os'] == 'CentOS' %}
 centos-release-openstack-liberty:
    pkg:
      - require_in:
        - pkg: neutron-plugin-openvswitch-agent
  neutron-ovs-cleanup:
    pkg:
      - require:
        - service: neutron-metadata-agent
{% endif %}