#! /usr/bin/env python

import json
from pip.util import get_installed_distributions

packages = []

for dist in get_installed_distributions():
    packages.append(
        {
            "name": dist.project_name,
            "version": dist.version,
            "location": dist.location,
            "dependencies": map(lambda dependency: dependency.project_name, dist.requires())
        }
    )

print json.dumps(packages)
