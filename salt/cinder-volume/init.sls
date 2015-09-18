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
      - KEYSTONE_INTERNAL_ENDPOINT: {{ pillar['keystone']['internal_endpoint'] }}
      - KEYSTONE_ADMIN_ENDPOINT: {{ pillar['keystone']['admin_endpoint'] }}
      - MY_IP: {{ pillar[grains['id']]['my_ip'] }}
      - CINDER_PASS: {{ pillar['cinder']['cinder_pass'] }}
      - GLANCE_HOST: {{ pillar['glance']['internal_endpoint'] }}
    - volumes:
      - /etc/cinder/: /etc/cinder/

{% if grains['oscodename'] == 'jessie' %}
cinder-volume:
  pkg.installed:
    - pkgs:
      - cinder-volume 
      - python-mysqldb
      - ceph-common
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

{% if grains['oscodename'] == 'trusty' %}
cinder-volume:
  pkg.installed:
    - pkgs:
      - cinder-volume 
      - python-mysqldb
      - ceph-common
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