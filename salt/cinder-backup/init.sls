{{ pillar['docker']['registry'] }}/lzh/cinder-backup:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

cinder-backup:
  docker.running:
    - name: cinder-backup
    - image: {{ pillar['docker']['registry'] }}/lzh/cinder-backup:kilo
    - environment:
      - CINDER_DB: {{ pillar['cinder']['db_host'] }}
      - CINDER_DBPASS: {{ pillar['cinder']['db_password'] }}
      - RABBIT_HOST: {{ pillar['cinder']['rabbit_host'] }}
      - RABBIT_USERID: {{ pillar['cinder']['rabbit_userid'] }}
      - RABBIT_PASSWORD: {{ pillar['cinder']['rabbit_password'] }}
    - volumes:
      - /opt/openstack/cinder-backup/: /etc/cinder/
      - /opt/openstack/log/cinder-backup/: /var/log/cinder/
      - /etc/ceph: /etc/ceph
    - network_mode: host
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/cinder-backup