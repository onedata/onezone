import inspect


def test_file(relative_file_path):
    """Returns a path to file located in {test_name}_data directory, where
    {test_name} is name of the test module that called this function.
    example: using tesutils.test_file('my_file') in my_test.py will return 'tests/my_test_data/my_file'
    """
    caller = inspect.stack()[1]
    caller_mod = inspect.getmodule(caller[0])
    caller_mod_file_path = caller_mod.__file__
    return '{0}_data/{1}'.format(caller_mod_file_path.rstrip('.py'), relative_file_path)
