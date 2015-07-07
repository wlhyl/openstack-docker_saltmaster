#!/bin/bash

if [ -z "$PILLAR_HTTP_ENDPOINT" ];then
  echo "error: PILLAR_HTTP_ENDPOINT not set"
  exit 1
fi

if [ ! -f /etc/keystone/.complete ];then
    cp -rp /salt/* /etc/salt/
    sed -i /pillarHttp/s#http://127.0.0.1:8000/api/#${PILLAR_HTTP_ENDPOINT}#g /etc/salt/master
    touch /etc/salt/.complete
fi

/usr/bin/supervisord -n