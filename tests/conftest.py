def pytest_addoption(parser):
    parser.addoption("--test-type", action="store", default=None,
                     help="type of test (cucumber, acceptance,"
                          "performance, packaging)")