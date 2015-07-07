# 运行salt-master
docker run -d -e PILLAR_HTTP_ENDPOINT=http://127.0.0.1/api/ -p 4506:4505 -p 4506:4506 10.64.0.50:5000/lzh/salt-master