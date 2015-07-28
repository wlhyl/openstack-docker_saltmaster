{{ pillar['docker']['registry'] }}/lzh/designate-central:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

designate-central:
  docker.running:
    - name: designate-central
    - image: {{ pillar['docker']['registry'] }}/lzh/designate-central:kilo
    - environment:
      - DESIGNATE_DB: {{ pillar['designate']['db_host'] }}
      - DESIGNATE_DBPASS: {{ pillar['designate']['db_password'] }}
      - RABBIT_HOST: {{ pillar['designate']['rabbit_host'] }}
      - RABBIT_USERID: {{ pillar['designate']['rabbit_userid'] }}
      - RABBIT_PASSWORD: {{ pillar['designate']['rabbit_password'] }}
      - KEYSTONE_ENDPOINT: {{ pillar['keystone']['endpoint'] }}
      - DESIGNATE_PASS: {{ pillar['designate']['designate_pass'] }}
    - volumes:
      - /opt/openstack/designate-central/: /etc/designate
      - /opt/openstack/log/designate-central/: /var/log/designate/
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/designate-central