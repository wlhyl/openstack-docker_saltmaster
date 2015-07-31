#节点有三种角色:
- controller
- compute
- network

# 设置节点角色
salt 'net*' grains.setval roles "['network']"
salt 'net*' grains.setval roles "['network', 'compute']"
salt 'net*' grains.remove roles network

# 运行salt-master
变量：PILLAR_HTTP_ENDPOINT是 saltviewer 的地址
docker run -d \
    -e PILLAR_HTTP_ENDPOINT=http://127.0.0.1/api/ \
    --name salt-master \
    -p 4505:4505 \
    -p 4506:4506 \
    -v /opt/salt:/etc/salt
    10.64.0.50:5000/lzh/salt-master

# 配置ntp
#在docker server 上配置ntp client作好时间同步

# 构建images
cd kilo
docker build -t lzh/openstackbase:kilo base
docker build -t lzh/mariadb:kilo mariadb
docker build -t lzh/keystone:kilo keystone
docker build -t lzh/glance:kilo glance


# 部署mysql
salt 'con*' state.sls mysql

# 部署keystone
salt 'con*' state.sls keystone

# 部署 glance
salt 'con*' state.sls glance

# 部署 rabbitmq
salt 'con*' state.sls rabbitmq

# 部署nova controller
## 部署 nova-api
salt 'con*' state.sls nova-api

## 部署 nova-cert
salt 'con*' state.sls nova-cert

## 部署nova-consoleauth
salt 'con*' state.sls nova-consoleauth

## 部署nova-scheduler
salt 'con*' state.sls nova-scheduler

## 部署nova-conductor
salt 'con*' state.sls nova-conductor

## 部署nova-novncproxy
salt 'con*' state.sls nova-novncproxy

# 部署nova-compute
salt 'com*' state.sls nova-compute
salt 'com*' state.sls neutron-plugin-openvswitch-agent

# 部署neutron-server
salt 'con*' state.sls neutron-server

# 部署 network
## 部署 neutron-plugin-openvswitch-agent
salt 'net*' state.sls neutron-plugin-openvswitch-agent

## 部署 neutron-l3-agent
salt 'net*' state.sls neutron-l3-agent

## neutron-dhcp-agent
salt 'net*' state.sls neutron-dhcp-agent

## neutron-metadata-agent
salt 'net*' state.sls neutron-metadata-agent

# 部署 designate
## 部署 designate
salt 'con*' state.sls bind9
salt 'con*' state.sls designate-api
salt 'con*' state.sls designate-central
salt 'con*' state.sls designate-mdns
salt 'con*' state.sls designate-pool-manager
## 恢复 bind9
### 启动bind9
salt 'con*' state.sls bind9
### 恢复 record
#### 进入bind9
```bash
docker exec -it bind9 /bin/bash
```
#### 添加zone
```bash
rndc addzone ynnic.org '{ type slave; masters { *MDNS_IP* port 5354;}; \
     file "slave.ynnic.org.*DOMAIN_ID*"; };
```
如：
```bash
rndc addzone ynnic.org '{ type slave; masters { 10.64.0.52 port 5354;}; \
     file "slave.ynnic.org.d04fa5e4-634a-493f-b31e-46098be8d793"; };
```
