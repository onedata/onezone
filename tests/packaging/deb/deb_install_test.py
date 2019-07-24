import pytest
from tests.test_common import *
from environment import docker, env

file_dir = os.path.dirname(os.path.realpath(__file__))

with open('./RELEASE', 'r') as f:
    release = f.read().replace('\n', '')

class Distribution(object):

    def __init__(self, request):
        package_dir = os.path.join(os.getcwd(), 'package/{0}/binary-amd64'.
                                   format(request.param))
        config_dir = os.path.join(file_dir, 'deb_install_test_data')

        self.name = request.param
        self.image = 'ubuntu:{0}'.format(self.name)
        self.container = docker.run(interactive=True,
                                    tty=True,
                                    detach=True,
                                    image=self.image,
                                    hostname='onezone.test.local',
                                    stdin=sys.stdin,
                                    stdout=sys.stdout,
                                    stderr=sys.stderr,
                                    volumes=[
                                        (package_dir, '/root/pkg', 'ro'),
                                        (config_dir, '/root/data', 'ro')
                                    ])

        request.addfinalizer(lambda: docker.remove(
            [self.container], force=True, volumes=True))


@pytest.fixture(scope='module')
def setup_command():
    return 'apt-get update && ' \
        'apt-get install -y ca-certificates locales python wget python-pip gnupg2 libssl1.0.0 && ' \
        'pip install requests && ' \
        'wget -qO- {url}/onedata.gpg.key | apt-key add - && ' \
        'echo "deb {url}/apt/ubuntu/{{release}} {{dist}} main" > /etc/apt/sources.list.d/onedata.list && ' \
        'echo "deb-src {url}/apt/ubuntu/{{release}} {{dist}} main" >> /etc/apt/sources.list.d/onedata.list && ' \
        'apt-get update && ' \
        'locale-gen en_US.UTF-8'.format(url='http://packages.onedata.org')


@pytest.fixture(scope='module',
                params=['xenial', 'bionic'])
def onezone(request, setup_command):
    distribution = Distribution(request)
    command = setup_command.format(dist=distribution.name,
                                   release=release)

    assert 0 == docker.exec_(distribution.container,
                             interactive=True,
                             tty=True,
                             command=command)

    return distribution

def test_onezone_installation(onezone):
    assert 0 == docker.exec_(onezone.container,
                             interactive=True,
                             tty=True,
                             command='python /root/data/install_onezone.py ' \
                                     '{}'.format(onezone.name,))
