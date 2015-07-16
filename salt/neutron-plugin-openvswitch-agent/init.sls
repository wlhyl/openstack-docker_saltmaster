{{ pillar['docker']['registry'] }}/lzh/neutron-plugin-openvswitch-agent:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

neutron-plugin-openvswitch-agent:
  docker.running:
    - name: neutron-plugin-openvswitch-agent
    - image: {{ pillar['docker']['registry'] }}/lzh/neutron-plugin-openvswitch-agent:kilo
    - privileged: True
    - environment:
      - RABBIT_HOST: {{ pillar['neutron']['rabbit_host'] }}
      - RABBIT_USERID: {{ pillar['neutron']['rabbit_userid'] }}
      - RABBIT_PASSWORD: {{ pillar['neutron']['rabbit_password'] }}
      - KEYSTONE_ENDPOINT: {{ pillar['keystone']['endpoint'] }}
      - NEUTRON_PASS: {{ pillar['neutron']['neutron_pass'] }}
      - LOCAL_IP: {{ pillar['nova']['endpoint'] }}
    - volumes:
      - /opt/openstack/neutron-plugin-openvswitch-agent/: /etc/neutron/
      - /opt/openstack/log/neutron-plugin-openvswitch-agent/: /var/log/neutron/
    - network_mode: host
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/neutron-plugin-openvswitch-agent