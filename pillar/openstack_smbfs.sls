docker:
  registry: 10.64.0.50:5000
  
openstack:
  keystone.endpoint: http://10.127.0.11:35357/v2.0
  region: RegionOne
  keystone.token: lzh
  version: liberty

rabbitmq:
  rabbitmq_erlang_cookie: abc
  endpoint: 10.127.0.11
  rabbitmq_user: openstack
  rabbitmq_pass: openstack

mysql:
  root_password: 123456
  db_host: 10.127.0.11

bind9:
  allow_rndc_host: any
  rndc_key_secret: aG81KpUybEqISe+BPpJYng==

keystone:
  public_endpoint: 10.127.0.11
  internal_endpoint: 10.127.0.11
  admin_endpoint: 10.127.0.11
  db_password: keystone
  db_host: 10.127.0.11
  admin_token: lzh
  memcached_server: 10.127.0.11
  admin_pass: 123456 # openstack user admin
  email: admin@ynnic.in # openstack user admin email

glance:
  public_endpoint: 10.127.0.11
  internal_endpoint: 10.127.0.11
  admin_endpoint: 10.127.0.11
  db_host: 10.127.0.11
  db_password: glance 
  glance_pass: glance 
  email: glance@ynnic.in 


nova:
  public_endpoint: 10.127.0.11
  internal_endpoint: 10.127.0.11
  admin_endpoint: 10.127.0.11
  rabbit_host: 10.127.0.11
  rabbit_userid: openstack
  rabbit_password: openstack
  db_host: 10.127.0.11
  db_password: nova 
  novncproxy_base_url: 10.127.0.11
  nova_pass: nova 
  email: nova@ynnic.in 

neutron:
  public_endpoint: 10.127.0.11
  internal_endpoint: 10.127.0.11
  admin_endpoint: 10.127.0.11
  rabbit_host: 10.127.0.11
  rabbit_userid: openstack
  rabbit_password: openstack
  db_host: 10.127.0.11
  db_password: neutron 
  metadata_proxy_shared_secret: abc
  neutron_pass: neutron 
  email: neutron@ynnic.in

cinder:
  public_endpoint: 10.127.0.11
  internal_endpoint: 10.127.0.11
  admin_endpoint: 10.127.0.11
  rabbit_host: 10.127.0.11
  rabbit_userid: openstack
  rabbit_password: openstack
  db_host: 10.127.0.11
  db_password: neutron 
  cinder_pass: nova 
  email: cinder@ynnic.in


designate:
  public_endpoint: 10.127.0.11
  internal_endpoint: 10.127.0.11
  admin_endpoint: 10.127.0.11
  rabbit_host: 10.127.0.11
  rabbit_userid: openstack
  rabbit_password: openstack
  db_host: 10.127.0.11
  db_password: designate 
  designate_pass: nova 
  email: designate@ynnic.in


controller:
  my_ip: 10.127.0.11

compute0:
  my_ip: 10.127.0.12
  local_ip: 10.127.0.12
  volume_backend_name: compute0
  smb_pass: 123456

compute1:
  my_ip: 10.127.0.77
  local_ip: 10.127.0.77
  volume_backend_name: compute1
  smb_pass: 123456

# cinder smbfs 配置
smbfs:
  my_ip: 10.127.0.61
  volume_backend_name: smbfs0
  smbfs_server: 10.127.0.25
  smb_pass: 123456

network0:
  my_ip: 10.127.0.13
  local_ip: 10.127.0.13