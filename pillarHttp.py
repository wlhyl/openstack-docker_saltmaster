# -*- coding: utf-8 -*-
'''
安装salt-master
wget -q -O- \
"http://debian.saltstack.com/debian-salt-team-joehealy.gpg.key" \
| apt-key add -
deb http://debian.saltstack.com/debian jessie-saltstack main

Configuring the salt-master system ext_pillar
==================================
  ext_pillar:
    - pillarHttp: http://127.0.0.1:8000/api/
extension_modules: /srv/custom
mkdir -p /srv/custom/pillar
mkdir -p /srv/salt
mkdir -p /srv/pillar
cp pillarHttp.py /srv/custom/pillar
刷新pillar
  salt '*' saltutil.refresh_pillar

Module Documentation
====================
'''

# Import python libs
import logging
import requests


# Set up logging
log = logging.getLogger(__name__)


def ext_pillar(minion_id, pillar, apiBaseUrl):
    '''
            返回值
    {
        pillarName:{
            key: value,
        }
    }
    '''
    result = {}
#     apiBaseUrl = 'http://192.168.2.111:8000/api/cmdb/'
    minion2pillarUrl = apiBaseUrl + 'minion2pillar/%s/' % minion_id

    log.info("Querying saltviewer system Pillar for %r" % minion_id)
    r = requests.get(minion2pillarUrl)
    if r.status_code != 200:
        log.exception(
            'Query saltviewer system failed! \
            Error: http status %s' % (r.status_code)
        )
        return {}
    server = r.json()
    for pillarNameId in server['server']['pillarName']:
        pillarUrl = apiBaseUrl + 'pillars/%s/' % pillarNameId
        r = requests.get(pillarUrl)
        if r.status_code == 200:
            pillarName = r.json()['pillar']['pillarName']
            result[pillarName] = {}
            keyValueList = r.json()['pillar']['keyValue']
            for keyValue in keyValueList:
                for k in keyValue.keys():
                    result[pillarName][k] = keyValue[k]
        else:
            log.exception(
                'Query cmdb system failed! url %s' % pillarUrl +
                'Error: http status %s' % (r.status_code)
            )
    return result

if __name__ == '__main__':
    print ext_pillar('test', 'a')
