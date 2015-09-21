# 环境说明
- 控制controller 10.127.0.59
- 计算compute0 10.127.0.60
- 网络节点 network 10.127.0.61
- tunel 走管理网络

# 预安装
## 准备 salt-master
变量：PILLAR_HTTP_ENDPOINT是 saltviewer 的地址
```bash
docker run -d \
    -e PILLAR_HTTP_ENDPOINT=http://127.0.0.1/api/ \
    --name salt-master \
    -p 4505:4505 \
    -p 4506:4506 \
    -v /opt/salt:/etc/salt \
    -v /opt/salt/srv:/srv \
    10.64.0.50:5000/lzh/salt-master

docker run -d \
    -e PILLAR_HTTP_ENDPOINT=http://127.0.0.1/api/ \
    --name salt-master \
    --net=host \
    -v /opt/salt/etc:/etc/salt \
    -v /opt/salt/srv:/srv \
    10.64.0.50:5000/lzh/salt-master
```
## 准备节点
推荐jessie作控制节点
### jessie
```bash
echo deb http://repo.saltstack.com/apt/debian jessie contrib >/etc/apt/sources.list.d/saltstack.list
wget -O - https://repo.saltstack.com/apt/debian/SALTSTACK-GPG-KEY.pub | apt-key add -
apt-get update && apt-get install salt-minion
```
### trusty
```bash
add-apt-repository ppa:saltstack/salt
apt-get update
apt-get install salt-minion -y
```
### trusy作控制节点
trusty作控制节点需要作如下处理
#### 升级trustry内核
kernel 3.13.0-63 的trusty有一个bug, 运行下面命令，会报错，升级到 kernel 3.16.0-49 可以解决，kernel 3.13也不支持vhost，升级到3.16可以支持
```bash
docker run -it --rm --net=host ubuntu:trusty su -s /bin/sh
su: System error
```
```bash
apt-get install linux-image-3.16.0-49-generic
```
#### 编译nsenter, jessie上使用的是util-linux  2.25.2-6
```bash
apt-get install wget gcc pkg-config make -y
docker run -it --rm --net=host -v /tmp/nsenter:/tmp/nsenter 10.64.0.50:5000/lzh/openstackbase:kilo /bin/bash
https://www.kernel.org/pub/linux/utils/util-linux/v2.25/util-linux-2.25.2.tar.gz
tar xvzf util-linux-2.25.2.tar.gz
cd util-linux-2.25.2
./configure --without-ncurses --without-python
cp nsenter /tmp/nsenter/
exit
cp /tmp/nsenter/nsenter /usr/local/bin/
```
### 安装docker 1.6.2
```bash
echo deb https://get.docker.com/ubuntu docker main > /etc/apt/sources.list.d/docker.list
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
apt-get update
apt-get install lxc-docker-1.6.2
```
### 安装pip
```bash
salt '*' pkg.install python-setuptools
salt '*' cmd.run 'easy_install -i http://mirrors.aliyun.com/pypi/simple/ pip'
salt 'con*' pip.install pip upgrade=True
salt '*' cmd.run 'pip install docker-py==1.2.3 -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com'
```
### 在controller节点上安装python-openstackclient
```bash
salt 'controller' pkg.install pkgs='["python-dev", "gcc"]'
salt 'controller' cmd.run 'pip install python-openstackclient -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com'
```
### 在controller节点上安装python-mysqldb
```bash
salt 'controller' pkg.install python-mysqldb
```
## 设置pillar
### 编辑top.sls
```bash
cat /srv/pillar/top.sls 
base:
  '*':
    - openstack
```
### 编辑openstack.sls
```bash
cat openstack.sls   
docker:
  registry: 10.64.0.50:5000
  
openstack:
  keystone.endpoint: http://10.127.0.59:35357/v2.0
  region: RegionOne
  keystone.token: lzh

rabbitmq:
  rabbitmq_erlang_cookie: abc
  endpoint: 10.127.0.59
  rabbitmq_user: openstack
  rabbitmq_pass: openstack

mysql:
  root_password: 123456
  db_host: 10.127.0.59

bind9:
  allow_rndc_host: any
  rndc_key_secret: aG81KpUybEqISe+BPpJYng==

keystone:
  public_endpoint: 10.127.0.59
  internal_endpoint: 10.127.0.59
  admin_endpoint: 10.127.0.59
  db_password: keystone
  db_host: 10.127.0.59
  admin_token: lzh
  memcached_server: 10.127.0.59
  admin_pass: 123456 # openstack user admin
  email: admin@ynnic.in # openstack user admin email

glance:
  public_endpoint: 10.127.0.59
  internal_endpoint: 10.127.0.59
  admin_endpoint: 10.127.0.59
  db_host: 10.127.0.59
  db_password: glance 
  glance_pass: glance 
  email: glance@ynnic.in 


nova:
  public_endpoint: 10.127.0.59
  internal_endpoint: 10.127.0.59
  admin_endpoint: 10.127.0.59
  rabbit_host: 10.127.0.59
  rabbit_userid: openstack
  rabbit_password: openstack
  db_host: 10.127.0.59
  db_password: nova 
  novncproxy_base_url: 10.127.0.59
  nova_pass: nova 
  email: nova@ynnic.in 

neutron:
  public_endpoint: 10.127.0.59
  internal_endpoint: 10.127.0.59
  admin_endpoint: 10.127.0.59
  rabbit_host: 10.127.0.59
  rabbit_userid: openstack
  rabbit_password: openstack
  db_host: 10.127.0.59
  db_password: neutron 
  metadata_proxy_shared_secret: abc
  neutron_pass: neutron 
  email: 10.127.0.59 

cinder:
  public_endpoint: 10.127.0.59
  internal_endpoint: 10.127.0.59
  admin_endpoint: 10.127.0.59
  rabbit_host: 10.127.0.59
  rabbit_userid: openstack
  rabbit_password: openstack
  db_host: 10.127.0.59
  db_password: neutron 
  cinder_pass: nova 
  email: 10.127.0.59 


designate:
  public_endpoint: 10.127.0.59
  internal_endpoint: 10.127.0.59
  admin_endpoint: 10.127.0.59
  rabbit_host: 10.127.0.59
  rabbit_userid: openstack
  rabbit_password: openstack
  db_host: 10.127.0.59
  db_password: designate 
  designate_pass: nova 
  email: 10.127.0.59 


controller:
  my_ip: 10.127.0.59

compute0:
  my_ip: 10.127.0.60
  local_ip: 10.127.0.60

network:
  my_ip: 10.127.0.61
  local_ip: 10.127.0.61
```

# 设置角色
## 节点有三种角色:
- controller
- compute
- network

## 设置节点角色, controller可以不用设置role
```bash
salt 'net*' grains.setval roles "['network']"
salt 'net*' grains.setval roles "['network', 'compute']"
salt 'net*' grains.remove roles network
```

# 配置ntp
在所有节点 上配置ntp client作好时间同步

# 单节点配置
## master端推送模式
```bash
salt 'controller' state.sls controller
salt 'compute0' state.sls compute
salt 'network' state.sls netwokr
```
## client端拉取模式
### 编辑/srv/salt/top.sls
```bash
cat /srv/salt/top.sls
base:
  'controller':
    - controller
  'compute*':
    - compute
  'network':
    - network
```
### 在所有节点执行下面的命令
```bash
salt-call state.highstate 
```

# 配置注意事项
## mysql会作反向解析, 导致安装过程很慢，可以作如下 设置
```bash
docker exec -it mysql echo 10.127.0.59 controller >> /etc/hosts
```
## 安装过程中需要关注mysql的输出日志，如果有报错，需要修复，如数据表有未同步完成
```bash
docker logs mysql
```

# 多节点微服务配置
下面的步骤用于微服务模式配置

# 设置初始dns
## 编辑第一个节点/etc/hosts，添加如下几行，第一节点预先部署keystone, memcache, designate
```bash
10.64.0.52 keystone.ynnic.in
10.64.0.52 keystone.ynnic.in
10.64.0.52 keystone.ynnic.org
10.64.0.52 memcached.ynnic.in
10.64.0.52 db.ynnic.in
10.64.0.52 designate.ynnic.in
10.64.0.52 designate.ynnic.in
10.64.0.52 designate.ynnic.org
10.64.0.52 rabbit.ynnic.in
```
## 设置dns server 为本地
```bash
cat /etc/resolv.conf 
nameserver 10.64.0.52
```

# 部署bind9作为本地dns代理server，后面部署designate时，将些dns server, 添加到desigante, 用作解析本地域名
```bash
salt 'con*' state.sls bind9
```

# 部署mysql
```bash
salt 'con*' state.sls mysql
```

# 部署memcached
```bash
salt 'con*' state.sls memcached
```

# 部署keystone
## 部署keystone
```bash
salt 'con*' state.sls keystone
```
## 调整keystone使用v3 api
```bash
mv /etc/keystone/policy.json /etc/keystone/policy.v2.json
cp /etc/keystone/policy.v3.json /etc/keystone/policy.json
docker restart keystone

export OS_TOKEN=lzh
export OS_URL=http://10.64.0.52:35357/v3
openstack  --os-identity-api-version 3 role add --user admin --domain default admin
```

# 部署 rabbitmq
```bash
salt 'con*' state.sls rabbitmq
```

# 部署 designate
## 部署 designate
```bash
salt 'con*' state.sls bind9
salt 'con*' state.sls designate-api
salt 'con*' state.sls designate-central
salt 'con*' state.sls designate-mdns
salt 'con*' state.sls designate-pool-manager
```
## 恢复 bind9
### 启动bind9
```bash
salt 'con*' state.sls bind9
```
### 恢复 record
#### 进入bind9
```bash
docker exec -it bind9 /bin/bash
```
#### 添加zone
```bash
rndc addzone ynnic.org '{ type slave; masters { MDNS_IP port 5354;}; \
     file "slave.ynnic.org.DOMAIN_ID"; };
```
如：
```bash
rndc addzone ynnic.org '{ type slave; masters { 10.64.0.52 port 5354;}; \
     file "slave.ynnic.org.d04fa5e4-634a-493f-b31e-46098be8d793"; };
```
## 解析ynnic.in
### 设置
```bash
designate server-create --name ns.ynnic.in.
designate domain-create --name ynnic.in. --email mail@ynnic.in
designate domain-create --name 0.64.10.in-addr.arpa. --email mail@ynnic.in
designate record-create --name ns --type A --data 10.64.0.52 c43f5fff-35a1-4ae6-96b1-40eb24d585b1
designate record-create --name 52 --type PTR --data controller.ynnic.in. 979588b2-b533-4fa5-a007-dd4141f162a3
```
### 需要解析的域名
```bash
10.64.0.52 designate.ynnic.org
10.64.0.52 designate.ynnic.in
10.64.0.52 keystone.ynnic.org
10.64.0.52 keystone.ynnic.in
10.64.0.52 keystone.ynnic.in
10.64.0.52 designate.ynnic.in
10.64.0.52 memcached.ynnic.in
10.64.0.52 db.ynnic.in
10.64.0.52 rabbit.ynnic.in
10.64.0.52 keystone.ynnic.in
10.64.0.52 designate.ynnic.in
10.64.0.52 glance.ynnic.in
10.64.0.52 nova.ynnic.in
10.64.0.52 neutron.ynnic.in
10.64.0.52 cinder.ynnic.in
```

# 部署 glance
```bash
salt 'con*' state.sls glance-api
salt 'con*' state.sls glance-registry
```

# 部署nova controller
```bash
salt 'con*' state.sls nova-api
salt 'con*' state.sls nova-cert
salt 'con*' state.sls nova-conductor
salt 'con*' state.sls nova-consoleauth
salt 'con*' state.sls nova-scheduler
salt 'con*' state.sls nova-novncproxy
```

# 部署nova-compute
```bash
salt 'com*' state.sls nova-compute
salt 'com*' state.sls neutron-plugin-openvswitch-agent
```

# 部署neutron-server
```bash
salt 'con*' state.sls neutron-server
```

# 部署 network
## 部署 neutron-plugin-openvswitch-agent
```bash
salt 'net*' state.sls neutron-plugin-openvswitch-agent
```

## 部署 neutron-l3-agent
```bash
salt 'net*' state.sls neutron-l3-agent
```

## neutron-dhcp-agent
```bash
salt 'net*' state.sls neutron-dhcp-agent
```

## neutron-metadata-agent
```bash
salt 'net*' state.sls neutron-metadata-agent
```

# 部署 cinder
## 部署 cinder-api
```bash
salt 'con*' state.sls cinder-api
```
## 部署 cinder-scheduler
```bash
salt 'con*' state.sls cinder-scheduler
```
## 部署cinder-volume
```bash
salt 'cinder-volume*' state.sls cinder-volume
```
## 部署cinder-backup
未完成
cinder-backup需要和cinder-volume部署在一起
```bash
salt 'cinder-volume*' state.sls cinder-backup
```
