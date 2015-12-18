docker:
  registry: 10.64.0.50:5000
  
openstack:
  keystone.endpoint: http://10.127.0.37:35357/v2.0
  region: RegionOne
  keystone.token: lzh
  version: liberty

rabbitmq:
  rabbitmq_erlang_cookie: abc
  endpoint: 10.127.0.37
  rabbitmq_user: openstack
  rabbitmq_pass: openstack

mysql:
  root_password: 123456
  db_host: 10.127.0.37
  version: 5.5.47

bind9:
  allow_rndc_host: any
  rndc_key_secret: aG81KpUybEqISe+BPpJYng==

keystone:
  public_endpoint: 10.127.0.37
  internal_endpoint: 10.127.0.37
  admin_endpoint: 10.127.0.37
  db_password: keystone
  db_host: 10.127.0.37
  admin_token: lzh
  memcached_server: 10.127.0.37
  admin_pass: 123456 # openstack user admin
  email: admin@ynnic.in # openstack user admin email

glance:
  public_endpoint: 10.127.0.37
  internal_endpoint: 10.127.0.37
  admin_endpoint: 10.127.0.37
  db_host: 10.127.0.37
  db_password: glance 
  glance_pass: glance 
  email: glance@ynnic.in 


nova:
  public_endpoint: 10.127.0.37
  internal_endpoint: 10.127.0.37
  admin_endpoint: 10.127.0.37
  rabbit_host: 10.127.0.37
  rabbit_userid: openstack
  rabbit_password: openstack
  db_host: 10.127.0.37
  db_password: nova 
  novncproxy_base_url: 10.127.0.37
  nova_pass: nova 
  email: nova@ynnic.in 

neutron:
  public_endpoint: 10.127.0.37
  internal_endpoint: 10.127.0.37
  admin_endpoint: 10.127.0.37
  rabbit_host: 10.127.0.37
  rabbit_userid: openstack
  rabbit_password: openstack
  db_host: 10.127.0.37
  db_password: neutron 
  metadata_proxy_shared_secret: abc
  neutron_pass: neutron 
  email: neutron@ynnic.in

cinder:
  public_endpoint: 10.127.0.37
  internal_endpoint: 10.127.0.37
  admin_endpoint: 10.127.0.37
  rabbit_host: 10.127.0.37
  rabbit_userid: openstack
  rabbit_password: openstack
  db_host: 10.127.0.37
  db_password: neutron 
  cinder_pass: nova 
  email: cinder@ynnic.in


designate:
  public_endpoint: 10.127.0.37
  internal_endpoint: 10.127.0.37
  admin_endpoint: 10.127.0.37
  rabbit_host: 10.127.0.37
  rabbit_userid: openstack
  rabbit_password: openstack
  db_host: 10.127.0.37
  db_password: designate 
  designate_pass: nova 
  email: designate@ynnic.in


con:
  my_ip: 10.127.0.37
  local_ip: 10.127.0.37