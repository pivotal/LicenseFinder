#!/usr/bin/env python

import json
from pip.req import parse_requirements
from pip.download import PipSession
from pip._vendor import pkg_resources
from pip._vendor.six import print_

requirements = [req.req for req
                in parse_requirements('requirements.txt', session=PipSession())]

transform = lambda dist: {
        'name': dist.project_name,
        'version': dist.version,
        'location': dist.location,
        'dependencies': list(map(lambda dependency: dependency.project_name, dist.requires())),
        }

packages = [transform(dist) for dist
            in pkg_resources.working_set.resolve(requirements)]

print_(json.dumps(packages))
