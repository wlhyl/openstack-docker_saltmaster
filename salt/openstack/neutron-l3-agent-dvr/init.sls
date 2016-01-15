{% from "global/map.jinja" import openstack_version with context %}

{{ pillar['docker']['registry'] }}/lzh/neutron-l3-agent:
  docker.pulled:
    - name: {{ pillar['docker']['registry'] }}/lzh/neutron-l3-agent-dvr
    - tag: {{ openstack_version }}
    - insecure_registry: True

neutron-l3-agent_docker:
  docker.running:
    - name: neutron-l3-agent-dvr
    - image: {{ pillar['docker']['registry'] }}/lzh/neutron-l3-agent-dvr:{{ openstack_version }}
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
      - docker: {{ pillar['docker']['registry'] }}/lzh/neutron-l3-agent

# liberty未测试 jessie
{% if grains['oscodename'] == 'jessie' %}
neutron-l3-agent:
  pkg.installed:
    - fromrepo: jessie-backports
    - require_in:
      - docker: neutron-l3-agent_docker
  service.running:
    - name: neutron-l3-agent
    - require:
      - docker: neutron-l3-agent_docker
    - watch:
      - docker: neutron-l3-agent_docker
{% endif %}

# liberty未测试 trusty
{% if grains['oscodename'] == 'trusty' %}
neutron-l3-agent:
  pkg.installed:
    - require_in:
      - docker: neutron-l3-agent_docker
  service.running:
    - name: neutron-l3-agent
    - require:
      - docker: neutron-l3-agent_docker
    - watch:
      - docker: neutron-l3-agent_docker
{% endif %}

{% if grains['os'] == 'CentOS' %}
neutron-l3-agent:
  pkg.installed:
    - name: openstack-neutron
    - require_in:
      - docker: neutron-l3-agent_docker
  service.running:
    - name: neutron-l3-agent
    - enable: True
    - require:
      - docker: neutron-l3-agent_docker
    - watch:
      - docker: neutron-l3-agent_docker
{% endif %}