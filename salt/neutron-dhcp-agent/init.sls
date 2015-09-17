{{ pillar['docker']['registry'] }}/lzh/neutron-dhcp-agent:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

neutron-dhcp-agent_docker:
  docker.running:
    - name: neutron-dhcp-agent
    - image: {{ pillar['docker']['registry'] }}/lzh/neutron-dhcp-agent:kilo
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
      - docker: {{ pillar['docker']['registry'] }}/lzh/neutron-dhcp-agent

{% if grains['oscodename'] == 'jessie' %}
neutron-dhcp-agent:
  pkg.installed:
    - fromrepo: jessie-backports
    - require_in:
      - docker: neutron-dhcp-agent_docker
  service.running:
    - name: neutron-dhcp-agent
    - require:
      - docker: neutron-dhcp-agent_docker
    - watch:
      - docker: neutron-dhcp-agent_docker
{% endif %}

{% if grains['oscodename'] == 'trusty' %}
neutron-dhcp-agent:
  pkg.installed:
    - require_in:
      - docker: neutron-dhcp-agent_docker
  service.running:
    - name: neutron-dhcp-agent
    - require:
      - docker: neutron-dhcp-agent_docker
    - watch:
      - docker: neutron-dhcp-agent_docker
{% endif %}