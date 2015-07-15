{{ pillar['docker']['registry'] }}/lzh/nova-compute:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

nova-compute:
  docker.running:
    - name: nova-compute
    - image: {{ pillar['docker']['registry'] }}/lzh/nova-compute:kilo
    - privileged: True
    - environment:
      - RABBIT_HOST: {{ pillar['nova']['rabbit_host'] }}
      - RABBIT_USERID: {{ pillar['nova']['rabbit_userid'] }}
      - RABBIT_PASSWORD: {{ pillar['nova']['rabbit_password'] }}
      - KEYSTONE_ENDPOINT: {{ pillar['keystone']['endpoint'] }}
      - MY_IP: {{ pillar[grains['id']]['my_ip'] }}
      - NOVA_PASS: {{ pillar['nova']['nova_pass'] }}
      - NOVNCPROXY_BASE_URL: {{ pillar[grains['id']]['novncproxy_base_url'] }}
      - GLANCE_ENDPOINT: {{ pillar['glance']['endpoint'] }}
    - volumes:
      - /opt/openstack/log/nova-compute/: /var/log/nova/
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/nova-compute