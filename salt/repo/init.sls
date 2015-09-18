{% if grains['oscodename'] == 'trusty' %}
ubuntu-cloud-keyring:
  pkg.installed

cloud-archive:
  pkgrepo.managed:
      - humanname: cloud-archive
      - name: deb http://ubuntu-cloud.archive.canonical.com/ubuntu trusty-updates/kilo main
      - dist: trusty-updates/kilo
      - comps: main
      - file: /etc/apt/sources.list.d/cloudarchive-kilo.list
      - require:
          - pkg: ubuntu-cloud-keyring
{% endif %}
