from __future__ import print_function

import sys
from subprocess import STDOUT, check_call, check_output

# get packages
packages = check_output(['ls', '/root/pkg']).split()
packages = sorted(packages, reverse=True)
oz_panel_package = \
    [path for path in packages if path.startswith('oz-panel')][0]
cluster_manager_package = \
    [path for path in packages if path.startswith('cluster-manager')][0]
oz_worker_package = \
    [path for path in packages if path.startswith('oz-worker')][0]
onezone_package = [path for path in packages
                       if path.startswith('onezone')][0]

# update repositories
check_call(['apt-get', '-y', 'update'])

# add locale
check_call(['locale-gen', 'en_US.UTF-8'])

# install dependencies
check_call(['apt-get', '-y', 'install', 'curl', 'apt-transport-https', 'wget'])

# get couchbase
check_call(['wget', 'http://packages.couchbase.com/releases/4.0.0/couchbase'
                    '-server-community_4.0.0-ubuntu14.04_amd64.deb'])

# install
check_call(['sh', '-c',
            'dpkg -i couchbase-server-community_4.0.0-ubuntu14.04_amd64.deb '
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

# disable gr cert verification
check_call(['sed', '-i', 's/{verify_oz_cert, true}/{verify_oz_cert, false}/g',
            '/etc/oz_panel/app.config'])
check_call(['service', 'oz_panel', 'restart'])

# download missing bundle
check_call(['wget', '-O', '/etc/ssl/cert.pem',
            'https://raw.githubusercontent.com/bagder/ca-bundle/master/'
            'ca-bundle.crt'])

# onezone configure and install
check_call(['oz_panel_admin', '--install', '/root/data/install.yml'])

# validate onezone is running
check_call(['service', 'cluster_manager', 'status'])
check_call(['service', 'oz_worker', 'status'])

# uninstall
check_call(['oz_panel_admin', '--uninstall'])

sys.exit(0)
