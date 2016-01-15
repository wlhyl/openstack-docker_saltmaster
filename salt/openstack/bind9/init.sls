{{ pillar['docker']['registry'] }}/lzh/bind9:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

bind9:
  docker.running:
    - name: bind9
    - image: {{ pillar['docker']['registry'] }}/lzh/bind9:kilo
    - environment:
      - RNDC_KEY_SECRET: {{ pillar['bind9']['rndc_key_secret'] }}
      - ALLOW_RNDC_HOST: {{ pillar['bind9']['allow_rndc_host'] }}
    - network_mode: host
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/bind9