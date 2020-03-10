#!/usr/bin/env python

import json
import sys

try:
        from pip._internal.req import parse_requirements
except ImportError:
        from pip.req import parse_requirements

try:
    # since pip 19.3
    from pip._internal.network.session import PipSession
except ImportError:
    try:
        # since pip 10
        from pip._internal.download import PipSession
    except ImportError:
        from pip.download import PipSession

from pip._vendor import pkg_resources
from pip._vendor.six import print_

reqs = []
for req in parse_requirements(sys.argv[1], session=PipSession()):
    if req.req == None or (req.markers != None and not req.markers.evaluate()): continue
    reqs.append(req)

requirements = [pkg_resources.Requirement.parse(str(req.req)) for req in reqs]

transform = lambda dist: {
        'name': dist.project_name,
        'version': dist.version,
        'location': dist.location,
        'dependencies': list(map(lambda dependency: dependency.project_name, dist.requires())),
        }

packages = [transform(dist) for dist
            in pkg_resources.working_set.resolve(requirements)]

print_(json.dumps(packages))
