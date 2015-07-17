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
      - KEYSTONE_ENDPOINT: {{ pillar['keystone']['endpoint'] }}
      - NEUTRON_PASS: {{ pillar['neutron']['neutron_pass'] }}
      - LOCAL_IP: {{ pillar[grains['id']]['local_ip'] }}
      - NOVA_ENDPOINT: {{ pillar['nova']['endpoint'] }}
      - METADATA_PROXY_SHARED_SECRET: {{ pillar['neutron']['metadata_proxy_shared_secret'] }}
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
    - name: neutron-openvswitch-agent
    - require:
      - docker: neutron-metadata-agent_docker
    - watch:
      - docker: neutron-metadata-agent_docker

net.ipv4.ip_forward:
  sysctl.present:
    - value: 1

net.ipv4.conf.all.rp_filter:
  sysctl.present:
    - value: 0
net.ipv4.conf.default.rp_filter:
  sysctl.present:
    - value: 0

br-ex:
  cmd.run:
    - name: ovs-vsctl add-br br-ex
    - unless: ovs-vsctl br-exists br-ex
    - require:
      - pkg: neutron-plugin-openvswitch-agent
    - require_in:
      - service: neutron-plugin-openvswitch-agent