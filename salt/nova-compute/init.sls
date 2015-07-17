{{ pillar['docker']['registry'] }}/lzh/nova-compute:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True
    - require_in:
      - docker: nova-compute_docker

nova-compute_docker:
  docker.running:
    - name: nova-compute
    - image: {{ pillar['docker']['registry'] }}/lzh/nova-compute:kilo
    - environment:
      - RABBIT_HOST: {{ pillar['nova']['rabbit_host'] }}
      - RABBIT_USERID: {{ pillar['nova']['rabbit_userid'] }}
      - RABBIT_PASSWORD: {{ pillar['nova']['rabbit_password'] }}
      - KEYSTONE_ENDPOINT: {{ pillar['keystone']['endpoint'] }}
      - MY_IP: {{ pillar[grains['id']]['my_ip'] }}
      - NOVA_PASS: {{ pillar['nova']['nova_pass'] }}
      - NOVNCPROXY_BASE_URL: {{ pillar['nova']['novncproxy_base_url'] }}
      - GLANCE_ENDPOINT: {{ pillar['glance']['endpoint'] }}
      - NEUTRON_ENDPOINT: {{ pillar['neutron']['endpoint'] }}
      - NEUTRON_PASS: {{ pillar['neutron']['neutron_pass'] }}
    - volumes:
      - /etc/nova/: /var/log/nova/

nova-compute:
  pkg.installed:
    - pkgs:
      - nova-compute
      - sysfsutils
    - fromrepo: jessie-backports
    - require_in:
      - nova-compute_docker
  service.running:
    - name: nova-compute
    - require:
      - docker: nova-compute_docker
    - watch:
      - docker: nova-compute_docker