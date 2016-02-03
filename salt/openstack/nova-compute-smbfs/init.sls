{% from "openstack/global/map.jinja" import openstack_version with context %}
{% from "openstack/global/map.jinja" import region with context %}

{{ pillar['docker']['registry'] }}/lzh/nova-compute-smbfs:
  docker.pulled:
    - tag: {{ openstack_version }}
    - insecure_registry: True
    - require_in:
      - docker: nova-compute_docker

nova-compute_docker:
  docker.running:
    - name: nova-compute
    - image: {{ pillar['docker']['registry'] }}/lzh/nova-compute-smbfs:{{ openstack_version }}
    - environment:
      - RABBIT_HOST: {{ pillar['nova']['rabbit_host'] }}
      - RABBIT_USERID: {{ pillar['nova']['rabbit_userid'] }}
      - RABBIT_PASSWORD: {{ pillar['nova']['rabbit_password'] }}
      - KEYSTONE_INTERNAL_ENDPOINT: {{ pillar['keystone']['internal_endpoint'] }}
      - KEYSTONE_ADMIN_ENDPOINT: {{ pillar['keystone']['admin_endpoint'] }}
      - MY_IP: {{ pillar[grains['id']]['my_ip'] }}
      - NOVA_PASS: {{ pillar['nova']['nova_pass'] }}
      - NOVNCPROXY_BASE_URL: {{ pillar['nova']['novncproxy_base_url'] }}
      - GLANCE_HOST: {{ pillar['glance']['internal_endpoint'] }}
      - NEUTRON_INTERNAL_ENDPOINT: {{ pillar['neutron']['internal_endpoint'] }}
      - NEUTRON_PASS: {{ pillar['neutron']['neutron_pass'] }}
      - REGION_NAME: {{ region }}
      - SMB_PASS: {{ pillar[grains['id']]['smb_pass'] }}
    - volumes:
      - /etc/nova/: /etc/nova/

# liberty 未为jessie准备镜像
{% if grains['oscodename'] == 'jessie' %}
nova-compute:
  pkg.installed:
    - pkgs:
      - nova-compute
      - sysfsutils
      - libguestfs-tools
      - python-guestfs
    - fromrepo: jessie-backports
    - require_in:
      - docker: nova-compute_docker
  service.running:
    - name: nova-compute
    - enable: True
    - require:
      - docker: nova-compute_docker
    - watch:
      - docker: nova-compute_docker
{% endif %}

# liberty 未为trusty准备镜像
{% if grains['oscodename'] == 'trusty' %}
nova-compute:
  pkg.installed:
    - pkgs:
      - nova-compute
      - sysfsutils
      - libguestfs-tools
      - python-guestfs
    - require_in:
      - docker: nova-compute_docker
  service.running:
    - name: nova-compute
    - enable: True
    - require:
      - docker: nova-compute_docker
    - watch:
      - docker: nova-compute_docker
{% endif %}

{% if grains['os'] == 'CentOS' %}
nova-compute:
  pkg.installed:
    - pkgs:
      - openstack-nova-compute
      - sysfsutils
    - require_in:
      - docker: nova-compute_docker
  service.running:
    - name: openstack-nova-compute
    - enable: True
    - require:
      - docker: nova-compute_docker
    - watch:
      - docker: nova-compute_docker
libvirtd:
  service.running:
    - name: libvirtd
    - enable: True
    - require:
      - docker: nova-compute_docker
    - require_in:
      - service: nova-compute
{% endif %}