def pytest_addoption(parser):
    parser.addoption("--test-type", action="store", default=None,
                     help="type of test (cucumber, acceptance,"
                          "performance, packaging)")
    parser.addoption('--docker-name', action="store", default='',
                     help='Used only with test_run.py: name of docker container '
                          'to be connected to scenario network')