{{ pillar['docker']['registry'] }}/lzh/designate-mdns:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

designate-mdns:
  docker.running:
    - name: designate-mdns
    - image: {{ pillar['docker']['registry'] }}/lzh/designate-mdns:kilo
    - environment:
      - DESIGNATE_DB: {{ pillar['designate']['db_host'] }}
      - DESIGNATE_DBPASS: {{ pillar['designate']['db_password'] }}
      - RABBIT_HOST: {{ pillar['designate']['rabbit_host'] }}
      - RABBIT_USERID: {{ pillar['designate']['rabbit_userid'] }}
      - RABBIT_PASSWORD: {{ pillar['designate']['rabbit_password'] }}
    - volumes:
      - /opt/openstack/designate-mdns/: /etc/designate
      - /opt/openstack/log/designate-mdns/: /var/log/designate/
    - network_mode: host
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/designate-mdns