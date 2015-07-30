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
      - KEYSTONE_ENDPOINT: {{ pillar['keystone']['endpoint'] }}
      - DESIGNATE_PASS: {{ pillar['designate']['designate_pass'] }}
    - volumes:
      - /opt/openstack/designate-mdns/: /etc/designate
      - /opt/openstack/log/designate-mdns/: /var/log/designate/
    - ports:
      - "5354/tcp":
              HostIp: ""
              HostPort: "5354"
      - "5354/udp":
              HostIp: "0.0.0.0"
              HostPort: "5354"
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/designate-mdns