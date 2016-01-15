{% if grains['oscodename'] == 'trusty' %}
ubuntu-cloud-keyring:
  pkg.installed

cloud-archive:
  pkgrepo.managed:
      - humanname: cloud-archive
      - name: deb http://ubuntu-cloud.archive.canonical.com/ubuntu trusty-updates/liberty main
      - dist: trusty-updates/liberty
      - comps: main
      - file: /etc/apt/sources.list.d/cloudarchive-liberty.list
      - require:
          - pkg: ubuntu-cloud-keyring
{% endif %}

{% if grains['os'] == 'CentOS' %}
centos-release-openstack-liberty:
  pkg.installed
{% endif %}
