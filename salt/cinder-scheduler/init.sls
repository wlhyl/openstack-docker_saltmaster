{{ pillar['docker']['registry'] }}/lzh/cinder-scheduler:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True

cinder-scheduler:
  docker.running:
    - name: cinder-scheduler
    - image: {{ pillar['docker']['registry'] }}/lzh/cinder-scheduler:kilo
    - environment:
      - CINDER_DB: {{ pillar['cinder']['db_host'] }}
      - CINDER_DBPASS: {{ pillar['cinder']['db_password'] }}
      - RABBIT_HOST: {{ pillar['cinder']['rabbit_host'] }}
      - RABBIT_USERID: {{ pillar['cinder']['rabbit_userid'] }}
      - RABBIT_PASSWORD: {{ pillar['cinder']['rabbit_password'] }}
      - KEYSTONE_ENDPOINT: {{ pillar['keystone']['endpoint'] }}
      - MY_IP: {{ pillar[grains['id']]['my_ip'] }}
      - CINDER_PASS: {{ pillar['cinder']['cinder_pass'] }}
    - volumes:
      - /opt/openstack/cinder-scheduler/: /etc/cinder/
      - /opt/openstack/log/cinder-scheduler/: /var/log/cinder/
    - require:
      - docker: {{ pillar['docker']['registry'] }}/lzh/cinder-scheduler