# 运行salt-master
docker run -d \
    -e PILLAR_HTTP_ENDPOINT=http://127.0.0.1/api/ \
    --name salt-master \
    -p 4505:4505 \
    -p 4506:4506 \
    -v /opt/salt:/etc/salt
    10.64.0.50:5000/lzh/salt-master