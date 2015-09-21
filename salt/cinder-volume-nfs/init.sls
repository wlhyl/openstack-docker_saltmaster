{{ pillar['docker']['registry'] }}/lzh/cinder-volume-nfs:
  docker.pulled:
    - tag: kilo
    - insecure_registry: True
    - require_in:
      - docker: cinder-volume-nfs_docker

cinder-volume-nfs_docker:
  docker.running:
    - name: cinder-volume-nfs
    - image: {{ pillar['docker']['registry'] }}/lzh/cinder-volume-nfs:kilo
    - privileged: True
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
      - VOLUME_BACKEND_NAME: {{ pillar[grains['id']]['VOLUME_BACKEND_NAME'] }}
    - volumes:
      - /etc/cinder/: /etc/cinder/

{% if grains['oscodename'] == 'jessie' %}
cinder-volume:
  pkg.installed:
    - pkgs:
      - cinder-volume 
      - python-mysqldb
      - nfs-common
    - fromrepo: jessie-backports
    - require_in:
      - docker: cinder-volume-nfs_docker
  service.running:
    - name: cinder-volume
    - enable: True
    - require:
      - docker: cinder-volume-nfs_docker
    - watch:
      - docker: cinder-volume-nfs_docker
{% endif %}

{% if grains['oscodename'] == 'trusty' %}
cinder-volume:
  pkg.installed:
    - pkgs:
      - cinder-volume 
      - python-mysqldb
      - nfs-common
    - require_in:
      - docker: cinder-volume-nfs_docker
  service.running:
    - name: cinder-volume
    - enable: True
    - require:
      - docker: cinder-volume-nfs_docker
    - watch:
      - docker: cinder-volume-nfs_docker
{% endif %}