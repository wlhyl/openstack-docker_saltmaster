{{ pillar['docker']['registry'] }}/lzh/nova-scheduler:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

nova-scheduler:
  docker.running:
    - name: nova-scheduler
    - image: {{ pillar['docker']['registry'] }}/lzh/nova-scheduler:kilo
    - environment:
      - NOVA_DB: {{ pillar['nova']['db_host'] }}
      - NOVA_DBPASS: {{ pillar['nova']['db_password'] }}
      - RABBIT_HOST: {{ pillar['nova']['rabbit_host'] }}
      - RABBIT_USERID: {{ pillar['nova']['rabbit_userid'] }}
      - RABBIT_PASSWORD: {{ pillar['nova']['rabbit_password'] }}
      - MY_IP: {{ pillar['nova']['my_ip'] }}
    - volumes:
      - /opt/openstack/log/nova-scheduler/: /var/log/nova/
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/nova-scheduler