from __future__ import print_function

import sys
from subprocess import STDOUT, check_call, check_output

# get packages
packages = check_output(['ls', '/root/pkg']).split()
packages = sorted(packages, reverse=True)
oz_panel_package = \
    [path for path in packages if path.startswith('oz-panel') and
     path.endswith('.rpm')][0]
cluster_manager_package = \
    [path for path in packages if path.startswith('cluster-manager') and
     path.endswith('.rpm')][0]
oz_worker_package = \
    [path for path in packages if path.startswith('oz-worker') and
     path.endswith('.rpm')][0]
onezone_package = \
    [path for path in packages if path.startswith('onezone') and
     path.endswith('.rpm')][0]

# get couchbase
check_call(['wget', 'http://packages.couchbase.com/releases/4.0.0/couchbase'
                    '-server-community-4.0.0-centos7.x86_64.rpm'])

# install all
check_call(['dnf', '-y', 'install',
            'couchbase-server-community-4.0.0-centos7.x86_64.rpm'],
           stderr=STDOUT)
check_call(['dnf', '-y', 'install', '/root/pkg/' + oz_panel_package],
           stderr=STDOUT)
check_call(['dnf', '-y', 'install', '/root/pkg/' + cluster_manager_package],
           stderr=STDOUT)
check_call(['dnf', '-y', 'install', '/root/pkg/' + oz_worker_package],
           stderr=STDOUT)
check_call(['dnf', '-y', 'install', '/root/pkg/' + onezone_package],
           stderr=STDOUT)

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
check_call(['oz_panel_admin', '--install', '/root/data/install.cfg'])

# validate onezone is running
check_call(['service', 'cluster_manager', 'status'])
check_call(['service', 'oz_worker', 'status'])

# uninstall
check_call(['oz_panel_admin', '--uninstall'])

sys.exit(0)
