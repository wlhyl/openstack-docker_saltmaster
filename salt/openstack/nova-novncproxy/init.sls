{% from "openstack/global/map.jinja" import openstack_version with context %}

{{ pillar['docker']['registry'] }}/lzh/nova-novncproxy:
  docker.pulled:
    - tag: {{ openstack_version }}
    - insecure_registry: True

nova-novncproxy:
  docker.running:
    - name: nova-novncproxy
    - image: {{ pillar['docker']['registry'] }}/lzh/nova-novncproxy:{{ openstack_version }}
    - environment:
      - RABBIT_HOST: {{ pillar['nova']['rabbit_host'] }}
      - RABBIT_USERID: {{ pillar['nova']['rabbit_userid'] }}
      - RABBIT_PASSWORD: {{ pillar['nova']['rabbit_password'] }}
      - MY_IP: {{ pillar[grains['id']]['my_ip'] }}
    - volumes:
      - /opt/openstack/nova-novncproxy/: /etc/nova/
      - /opt/openstack/log/nova-novncproxy/: /var/log/nova/
    - network_mode: host
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/nova-novncproxy