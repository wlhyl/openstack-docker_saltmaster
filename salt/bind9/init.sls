{{ pillar['docker']['registry'] }}/lzh/bind9:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

bind9:
  docker.running:
    - name: bind9
    - image: {{ pillar['docker']['registry'] }}/lzh/bind9:kilo
    - environment:
      - RNDC_KEY_SECRET: {{ pillar['keystone']['endpoint'] }}
      - ALLOW_RNDC: user
    - ports:
        - "53/tcp":
               HostIp: ""
               HostPort: "53"
    - ports:
        - "53/udp":
               HostIp: ""
               HostPort: "53"
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/bind9