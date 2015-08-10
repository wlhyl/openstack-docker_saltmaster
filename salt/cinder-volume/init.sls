{{ pillar['docker']['registry'] }}/lzh/cinder-volume:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True
    - require_in:
      - docker: cinder-volume_docker

cinder-volume_docker:
  docker.running:
    - name: cinder-volume
    - image: {{ pillar['docker']['registry'] }}/lzh/cinder-volume:kilo
    - environment:
      - CINDER_DB: {{ pillar['cinder']['db_host'] }}
      - CINDER_DBPASS: {{ pillar['cinder']['db_password'] }}
      - RABBIT_HOST: {{ pillar['cinder']['rabbit_host'] }}
      - RABBIT_USERID: {{ pillar['cinder']['rabbit_userid'] }}
      - RABBIT_PASSWORD: {{ pillar['cinder']['rabbit_password'] }}
      - KEYSTONE_ENDPOINT: {{ pillar['keystone']['endpoint'] }}
      - MY_IP: {{ pillar[grains['id']]['my_ip'] }}
      - CINDER_PASS: {{ pillar['cinder']['cinder_pass'] }}
      - GLANCE_ENDPOINT: {{ pillar['glance']['endpoint'] }}
    - volumes:
      - /etc/cinder/: /etc/cinder/

{% if grains['os'] == 'Debian' %}
cinder-volume:
  pkg.installed:
    - pkgs:
      - cinder-volume 
      - python-mysqldb
    - fromrepo: jessie-backports
    - require_in:
      - docker: cinder-volume_docker
  service.running:
    - name: cinder-volume
    - enable: True
    - require:
      - docker: cinder-volume_docker
    - watch:
      - docker: cinder-volume_docker
{% endif %}