import os
import pytest
from tests.test_common import *
from environment import docker, env

file_dir = os.path.dirname(os.path.realpath(__file__))

with open('./RELEASE', 'r') as f:
    release = f.read().replace('\n', '')

class Distribution(object):

    def __init__(self, request):
        package_dir = os.path.join(os.getcwd(), 'package/{0}/x86_64'.
                                   format(request.param))
        config_dir = os.path.join(file_dir, 'rpm_install_test_data')

        self.name = request.param
        self.container = docker.run(interactive=True,
                                    tty=True,
                                    detach=True,
                                    image='centos:7',
                                    hostname='onezone.test.local',
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
    return 'echo "proxy=http://proxy.devel.onedata.org:3128" >> /etc/yum.conf && ' \
        'sed -i "s/enabled=1/enabled=0/" /etc/yum/pluginconf.d/fastestmirror.conf && ' \
        'sed -i "s/mirrorlist/#mirrorlist/" /etc/yum.repos.d/CentOS-Base.repo && ' \
        'sed -i "s/#baseurl/baseurl/" /etc/yum.repos.d/CentOS-Base.repo && ' \
        'yum -y update && ' \
        'yum -y install epel-release && ' \
        'yum -y install ca-certificates python wget curl && ' \
        'yum -y install python-setuptools python-pip && ' \
        'pip install --upgrade pip==20.3.4 && ' \
        'pip install requests && ' \
        'curl -sSL "{url}/yum/{release}/onedata_centos_7x.repo" > /etc/yum.repos.d/onedata.repo' \
        .format(url='http://packages.onedata.org', release=release)


@pytest.fixture(scope='module',
                params=['centos-7-x86_64'])
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
                             command='python /root/data/install_onezone.py ' \
                                     '{}'.format(release,))
