import json
import requests
import sys
import time
from requests.packages.urllib3.exceptions import InsecureRequestWarning
from subprocess import STDOUT, check_call, check_output

requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

release = sys.argv[1]

EMERGENCY_USERNAME = 'onepanel'
EMERGENCY_PASSPHRASE = 'passphrase'

# get packages
packages = check_output(['ls', '/root/pkg']).split()
packages = sorted(packages, reverse=True)
oz_panel_package = \
    [path for path in packages if path.startswith('onedata{}-oz-panel'.format(release,)) and
     path.endswith('.rpm')][0]
cluster_manager_package = \
    [path for path in packages if path.startswith('onedata{}-cluster-manager'.format(release,)) and
     path.endswith('.rpm')][0]
oz_worker_package = \
    [path for path in packages if path.startswith('onedata{}-oz-worker'.format(release,)) and
     path.endswith('.rpm')][0]
onezone_package = \
    [path for path in packages if path.startswith('onedata{}-onezone'.format(release,)) and
     path.endswith('.rpm')][0]

# get couchbase
check_call(['wget', 'http://packages.onedata.org/yum/centos/7x/x86_64/'
                    'couchbase-server-community-4.5.1-centos7.x86_64.rpm'])

# install packages
check_call(['yum', '-y', 'install',
            './couchbase-server-community-4.5.1-centos7.x86_64.rpm'],
           stderr=STDOUT)
check_call(['yum', '-y', '--enablerepo=onedata',
            'install', '/root/pkg/' + oz_panel_package], stderr=STDOUT)
check_call(['yum', '-y', '--enablerepo=onedata',
            'install', '/root/pkg/' + cluster_manager_package], stderr=STDOUT)
check_call(['yum', '-y', '--enablerepo=onedata', 'install',
            '/root/pkg/' + oz_worker_package], stderr=STDOUT)
check_call(['yum', '-y', 'install', '/root/pkg/' + onezone_package],
           stderr=STDOUT)

# package installation validation
check_call(['service', 'oz_panel', 'status'])

# configure onezone
with open('/root/data/config.yml', 'r') as f:
    r = requests.put('https://127.0.0.1:9443/api/v3/onepanel/emergency_passphrase',
        headers={'content-type': 'application/json'},
        data=json.dumps({'newPassphrase': EMERGENCY_PASSPHRASE}),
        verify=False)
    assert r.status_code == 204

    r = requests.post(
        'https://127.0.0.1:9443/api/v3/onepanel/zone/configuration',
        auth=(EMERGENCY_USERNAME, EMERGENCY_PASSPHRASE),
        headers={'content-type': 'application/x-yaml'},
        data=f.read(),
        verify=False)

    loc = r.headers['location']
    status = 'running'
    while status == 'running':
        r = requests.get('https://127.0.0.1:9443' + loc,
                         auth=(EMERGENCY_USERNAME, EMERGENCY_PASSPHRASE),
                         verify=False)
        print(r.text)
        assert r.status_code == 200
        status = json.loads(r.text)['status']
        time.sleep(5)

assert status == 'ok'

# validate onezone configuration
check_call(['service', 'cluster_manager', 'status'])
check_call(['service', 'oz_worker', 'status'])

# stop onezone services
for service in ['workers', 'managers', 'databases']:
    r = requests.patch(
        'https://127.0.0.1:9443/api/v3/onepanel/zone/{0}?started=false'.format(
            service),
        auth=(EMERGENCY_USERNAME, EMERGENCY_PASSPHRASE),
        headers={'content-type': 'application/json'},
        verify=False)
    assert r.status_code == 204

sys.exit(0)
