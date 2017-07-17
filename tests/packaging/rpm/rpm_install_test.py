import pytest
from tests.test_common import *
from environment import docker, env

file_dir = os.path.dirname(os.path.realpath(__file__))


class Distribution(object):

    def __init__(self, request):
        package_dir = os.path.join(os.getcwd(), 'package/{0}/x86_64'.
                                   format(request.param))
        config_dir = os.path.join(file_dir, 'rpm_install_test_data')

        self.name = request.param
        self.container = docker.run(interactive=True,
                                    tty=True,
                                    detach=True,
                                    image='onedata/fedora-systemd:23',
                                    hostname='onezone.dev.local',
                                    privileged=True,
                                    stdin=sys.stdin,
                                    stdout=sys.stdout,
                                    stderr=sys.stderr,
                                    volumes=[
                                        (package_dir, '/root/pkg', 'ro'),
                                        (config_dir, '/root/data', 'ro')
                                    ],
                                    reflect=[('/sys/fs/cgroup', 'rw')])

        request.addfinalizer(lambda: docker.remove(
            [self.container], force=True, volumes=True))


@pytest.fixture(scope='module')
def setup_command():
    return 'dnf -y update && ' \
        'dnf -y install ca-certificates python wget python-setuptools && ' \
        'easy_install requests && ' \
        'wget -qO- "{url}/yum/onedata_fedora_23.repo" > /etc/yum.repos.d/onedata.repo' \
        .format(url='http://packages.onedata.org')


@pytest.fixture(scope='module',
                params=['fedora-23-x86_64'])
def onezone(request, setup_command):
    distribution = Distribution(request)

    assert 0 == docker.exec_(distribution.container,
                             interactive=True,
                             tty=True,
                             command=setup_command)

    return distribution


def test_onezone_installation(onezone):
    assert 0 == docker.exec_(onezone.container,
                             interactive=True,
                             tty=True,
                             command='python /root/data/install_onezone.py')
