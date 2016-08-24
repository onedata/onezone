from __future__ import print_function

import json
import requests
import sys
import time
from requests.packages.urllib3.exceptions import InsecureRequestWarning
from subprocess import STDOUT, check_call, check_output

requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

# get packages
packages = check_output(['ls', '/root/pkg']).split()
packages = sorted(packages, reverse=True)
oz_panel_package = \
    [path for path in packages if path.startswith('oz-panel')][0]
cluster_manager_package = \
    [path for path in packages if path.startswith('cluster-manager')][0]
oz_worker_package = \
    [path for path in packages if path.startswith('oz-worker')][0]
onezone_package = [path for path in packages if path.startswith('onezone')][0]

# update repositories
check_call(['apt-get', '-y', 'update'])

# add locale
check_call(['locale-gen', 'en_US.UTF-8'])

# install dependencies
check_call(['apt-get', '-y', 'install', 'curl', 'apt-transport-https', 'wget'])

# get couchbase
check_call(['wget', 'http://packages.couchbase.com/releases/4.1.0/couchbase'
                    '-server-community_4.1.0-ubuntu14.04_amd64.deb'])

# install
check_call(['sh', '-c',
            'dpkg -i couchbase-server-community_4.1.0-ubuntu14.04_amd64.deb '
            '; apt-get -f -y install'
            ], stderr=STDOUT)
check_call(['sh', '-c', 'dpkg -i /root/pkg/{package} ; apt-get -f -y '
                        'install'.format(package=oz_panel_package)
            ], stderr=STDOUT)
check_call(['sh', '-c', 'dpkg -i /root/pkg/{package} ; apt-get -f -y '
                        'install'.format(package=cluster_manager_package)
            ], stderr=STDOUT)
check_call(['sh', '-c', 'dpkg -i /root/pkg/{package} ; apt-get -f -y '
                        'install'.format(package=oz_worker_package)
            ], stderr=STDOUT)
check_call(['dpkg', '-i', '/root/pkg/{package}'.
           format(package=onezone_package)], stderr=STDOUT)

# package installation validation
check_call(['service', 'oz_panel', 'status'])
check_call(['ls', '/etc/cluster_manager/app.config'])
check_call(['ls', '/etc/oz_worker/app.config'])

# onezone configure and install
with open('/root/data/install.yml', 'r') as f:
    r = requests.post(
        'https://127.0.0.1:9443/api/v3/onepanel/zone/configuration',
        headers={'content-type': 'application/x-yaml'},
        data=f.read(),
        verify=False)

    loc = r.headers['location']
    status = 'running'
    while status == 'running':
        r = requests.get('https://127.0.0.1:9443' + loc,
                         auth=('admin1', 'Password1'),
                         verify=False)
        print(r.text)
        assert r.status_code == 200
        status = json.loads(r.text)['status']
        time.sleep(5)

assert status == 'ok'

# validate onezone is running
check_call(['service', 'cluster_manager', 'status'])
check_call(['service', 'oz_worker', 'status'])

# stop onezone services
for service in ['workers', 'managers', 'databases']:
    r = requests.patch(
        'https://127.0.0.1:9443/api/v3/onepanel/zone/{0}?started=false'.format(
            service),
        auth=('admin1', 'Password1'),
        headers={'content-type': 'application/json'},
        verify=False)
    assert r.status_code == 204

sys.exit(0)
