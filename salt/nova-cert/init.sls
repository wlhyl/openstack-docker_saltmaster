{{ pillar['docker']['registry'] }}/lzh/nova-cert:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

nova-cert:
  docker.running:
    - name: nova-cert
    - image: {{ pillar['docker']['registry'] }}/lzh/nova-cert:kilo
    - environment:
      - NOVA_DB: {{ pillar['nova']['db_host'] }}
      - NOVA_DBPASS: {{ pillar['nova']['db_password'] }}
      - RABBIT_HOST: {{ pillar['nova']['rabbit_host'] }}
      - RABBIT_USERID: {{ pillar['nova']['rabbit_userid'] }}
      - RABBIT_PASSWORD: {{ pillar['nova']['rabbit_password'] }}
      - MY_IP: {{ pillar[grains['id']]['my_ip'] }}
    - volumes:
      - /opt/openstack/nova-cert/: /etc/nova
      - /opt/openstack/log/nova-cert/: /var/log/nova/
    - network_mode: host
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/nova-cert