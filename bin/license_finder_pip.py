#!/usr/bin/env python

import json
from pip.utils import get_installed_distributions
from pip._vendor.six import print_

packages = []

for dist in get_installed_distributions():
    packages.append(
        {
            "name": dist.project_name,
            "version": dist.version,
            "location": dist.location,
            "dependencies": list(map(lambda dependency: dependency.project_name, dist.requires()))
        }
    )

print_(json.dumps(packages))
