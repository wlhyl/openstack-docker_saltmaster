#节点有三种角色:
- controller
- compute
- network

# 设置节点角色, controller可以不用设置role
```bash
salt 'net*' grains.setval roles "['network']"
salt 'net*' grains.setval roles "['network', 'compute']"
salt 'net*' grains.remove roles network
```

# 运行salt-master
变量：PILLAR_HTTP_ENDPOINT是 saltviewer 的地址
```bash
docker run -d \
    -e PILLAR_HTTP_ENDPOINT=http://127.0.0.1/api/ \
    --name salt-master \
    -p 4505:4505 \
    -p 4506:4506 \
    -v /opt/salt:/etc/salt
    10.64.0.50:5000/lzh/salt-master
```

# 配置ntp
在docker server 上配置ntp client作好时间同步

# 构建images
```bash
cd kilo
docker build -t lzh/openstackbase:kilo base
docker build -t lzh/mariadb:kilo mariadb
docker build -t lzh/keystone:kilo keystone
docker build -t lzh/glance:kilo glance
```

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
```bash
salt 'con*' state.sls keystone
```

# 部署 glance
```bash
salt 'con*' state.sls glance
```

# 部署 rabbitmq
```bash
salt 'con*' state.sls rabbitmq
```

# 部署nova controller
## 部署 nova-api
```bash
salt 'con*' state.sls nova-api
```

## 部署 nova-cert
```bash
salt 'con*' state.sls nova-cert
```

## 部署nova-consoleauth
```bash
salt 'con*' state.sls nova-consoleauth
```

## 部署nova-scheduler
```bash
salt 'con*' state.sls nova-scheduler
```

## 部署nova-conductor
salt 'con*' state.sls nova-conductor

## 部署nova-novncproxy
```bash
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