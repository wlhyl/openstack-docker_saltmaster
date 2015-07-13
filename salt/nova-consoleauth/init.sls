{{ pillar['docker']['registry'] }}/lzh/nova-consoleauth:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

nova-consoleauth:
  docker.running:
    - name: nova-consoleauth
    - image: {{ pillar['docker']['registry'] }}/lzh/nova-consoleauth:kilo
    - environment:
      - NOVA_DB: {{ pillar['nova']['db_host'] }}
      - NOVA_DBPASS: {{ pillar['nova']['db_password'] }}
      - RABBIT_HOST: {{ pillar['nova']['rabbit_host'] }}
      - RABBIT_USERID: {{ pillar['nova']['rabbit_userid'] }}
      - RABBIT_PASSWORD: {{ pillar['nova']['rabbit_password'] }}
      - MY_IP: {{ pillar['nova']['my_ip'] }}
    - volumes:
      - /opt/openstack/nova-cert/: /etc/nova
      - /opt/openstack/log/nova-cert/: /var/log/nova/
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/nova-consoleauth