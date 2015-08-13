{{ pillar['docker']['registry'] }}/lzh/nova-conductor:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

nova-conductor:
  docker.running:
    - name: nova-conductor
    - image: {{ pillar['docker']['registry'] }}/lzh/nova-conductor:kilo
    - environment:
      - NOVA_DB: {{ pillar['nova']['db_host'] }}
      - NOVA_DBPASS: {{ pillar['nova']['db_password'] }}
      - RABBIT_HOST: {{ pillar['nova']['rabbit_host'] }}
      - RABBIT_USERID: {{ pillar['nova']['rabbit_userid'] }}
      - RABBIT_PASSWORD: {{ pillar['nova']['rabbit_password'] }}
      - MY_IP: {{ pillar['nova']['my_ip'] }}
    - volumes:
      - /opt/openstack/nova-conductor/: /etc/nova
      - /opt/openstack/log/nova-conductor/: /var/log/nova/
    - network_mode: host
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/nova-conductor