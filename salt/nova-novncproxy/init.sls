{{ pillar['docker']['registry'] }}/lzh/nova-novncproxy:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

nova-novncproxy:
  docker.running:
    - name: nova-novncproxy
    - image: {{ pillar['docker']['registry'] }}/lzh/nova-novncproxy:kilo
    - environment:
      - RABBIT_HOST: {{ pillar['nova']['rabbit_host'] }}
      - RABBIT_USERID: {{ pillar['nova']['rabbit_userid'] }}
      - RABBIT_PASSWORD: {{ pillar['nova']['rabbit_password'] }}
      - VNCSERVER_PROXYCLIENT_ADDRESS: {{ pillar['nova']['vncserver_proxyclient_address'] }}
      - MY_IP: {{ pillar[grains['id']]['my_ip'] }}
    - volumes:
      - /opt/openstack/nova-novncproxy/: /etc/nova/
      - /opt/openstack/log/nova-novncproxy/: /var/log/nova/
    - network_mode: host
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/nova-novncproxy