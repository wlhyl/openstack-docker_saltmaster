{{ pillar['docker']['registry'] }}/lzh/nova-novncproxy:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

nova-novncproxy:
  docker.running:
    - name: nova-novncproxy
    - image: {{ pillar['docker']['registry'] }}/lzh/nova-novncproxy:kilo
    - environment:
      - VNCSERVER_PROXYCLIENT_ADDRESS: {{ pillar['nova']['vncserver_proxyclient_address'] }}
      - MY_IP: {{ pillar['nova']['my_ip'] }}
    - volumes:
      - /opt/openstack/log/nova-novncproxy/: /var/log/nova/
    - ports:
      - "6080/tcp":
              HostIp: ""
              HostPort: "6080"
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/nova-novncproxy