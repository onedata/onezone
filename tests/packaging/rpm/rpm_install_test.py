from tests import test_utils
from tests.test_common import *

package_dir = os.path.join(os.getcwd(), 'package/fedora-23-x86_64/x86_64')
scripts_dir = os.path.dirname(test_utils.test_file('rpm_install_script.py'))

from environment import docker, env
import sys


class TestRpmInstallation:
    # Test if installation has finished successfully
    def test_installation(self):
        command = 'dnf install -y python && ' \
                  'python /root/data/rpm_install_script.py'

        container = docker.run(tty=True,
                               interactive=True,
                               detach=True,
                               image='onedata/fedora-systemd:23',
                               hostname='devel.localhost.local',
                               workdir="/root",
                               run_params=['--privileged=true'],
                               stdin=sys.stdin,
                               stdout=sys.stdout,
                               stderr=sys.stderr,
                               volumes=[
                                   (package_dir, '/root/pkg', 'ro'),
                                   (scripts_dir, '/root/data', 'ro')
                               ],
                               reflect=[('/sys/fs/cgroup', 'rw')])

        try:
            assert 0 == docker.exec_(container,
                                     command=command,
                                     stdin=sys.stdin,
                                     stdout=sys.stdout,
                                     stderr=sys.stderr,
                                     interactive=True,
                                     tty=True)
        finally:
            docker.remove([container], force=True, volumes=True)
