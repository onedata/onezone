import os
import sys

_script_dir = os.path.dirname(os.path.realpath(__file__))

# Define variables for use in tests
project_dir = os.path.dirname(_script_dir)
docker_dir = os.path.join(project_dir, 'bamboos', 'docker')

# Append useful modules to the path
sys.path = [docker_dir] + sys.path
