{% from "global/map.jinja" import openstack_version with context %}

{{ pillar['docker']['registry'] }}/lzh/neutron-plugin-openvswitch-agent:
  docker.pulled:
    - tag: {{ openstack_version }}
    - insecure_registry: True

neutron-plugin-openvswitch-agent_docker:
  docker.running:
    - name: neutron-plugin-openvswitch-agent
    - image: {{ pillar['docker']['registry'] }}/lzh/neutron-plugin-openvswitch-agent:{{ openstack_version }}
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
      - docker: {{ pillar['docker']['registry'] }}/lzh/neutron-plugin-openvswitch-agent

# liberty未测试 jessie
{% if grains['oscodename'] == 'jessie' %}
neutron-plugin-openvswitch-agent:
  pkg.installed:
    - fromrepo: jessie-backports
    - require_in:
      - docker: neutron-plugin-openvswitch-agent_docker
  service.running:
    - name: neutron-openvswitch-agent
    - enable: True
    - require:
      - docker: neutron-plugin-openvswitch-agent_docker
    - watch:
      - docker: neutron-plugin-openvswitch-agent_docker
{% endif %}

# liberty未测试 trusy
{% if grains['oscodename'] == 'trusty' %}
neutron-plugin-openvswitch-agent:
  pkg.installed:
    - require_in:
      - docker: neutron-plugin-openvswitch-agent_docker
  service.running:
    - name: neutron-plugin-openvswitch-agent
    - enable: True
    - require:
      - docker: neutron-plugin-openvswitch-agent_docker
    - watch:
      - docker: neutron-plugin-openvswitch-agent_docker
{% endif %}

{% if grains['os'] == 'CentOS' %}
neutron-plugin-openvswitch-agent:
  pkg.installed:
    - pkgs:
      - iptables
      - openstack-neutron-openvswitch
    - require_in:
      - docker: neutron-plugin-openvswitch-agent_docker
  service.running:
    - name: neutron-openvswitch-agent
    - enable: True
    - require:
      - docker: neutron-plugin-openvswitch-agent_docker
    - watch:
      - docker: neutron-plugin-openvswitch-agent_docker

openvswitch:
  service.running:
    - name: openvswitch
    - enable: True
    - require:
      - docker: neutron-plugin-openvswitch-agent_docker
    - require_in:
      - service: neutron-plugin-openvswitch-agent
{% endif %}

{% if 'network' in grains['roles'] %}
net.ipv4.ip_forward:
  sysctl.present:
    - value: 1
{% endif %}

net.ipv4.conf.all.rp_filter:
  sysctl.present:
    - value: 0
net.ipv4.conf.default.rp_filter:
  sysctl.present:
    - value: 0

{% if 'compute' in grains['roles'] %}
net.bridge.bridge-nf-call-iptables:
  sysctl.present:
    - value: 1

net.bridge.bridge-nf-call-ip6tables:
  sysctl.present:
    - value: 1
{% endif %}

br-ex:
  cmd.run:
    - name: ovs-vsctl add-br br-ex
    - unless: ovs-vsctl br-exists br-ex
    - require:
      - pkg: neutron-plugin-openvswitch-agent
    - require_in:
      - service: neutron-plugin-openvswitch-agent

br-private:
  cmd.run:
    - name: ovs-vsctl add-br br-private
    - unless: ovs-vsctl br-exists br-private
    - require:
      - pkg: neutron-plugin-openvswitch-agent
    - require_in:
      - service: neutron-plugin-openvswitch-agent