{% if grains['os'] == 'CentOS' %}
neutron-ovs-cleanup:
  pkg.installed:
    - name: openstack-neutron
  service.running:
    - name: neutron-ovs-cleanup
    - enable: True
    - require:
      - pkg: neutron-ovs-cleanup
{% endif %}