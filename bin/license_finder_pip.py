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


reqs = []
for req in parse_requirements(sys.argv[1], session=PipSession()):
    try:
        if req.req is not None and (req.markers is None or req.markers.evaluate()):
            reqs.append(pkg_resources.Requirement.parse(str(req.req)))
    except AttributeError:
        # Since pip 20.1 (pip now takes care of markers at the resolve step)
        if req.requirement is not None:
            reqs.append(pkg_resources.Requirement.parse(str(req.requirement)))

transform = lambda dist: {
        'name': dist.project_name,
        'version': dist.version,
        'location': dist.location,
        'dependencies': list(map(lambda dependency: dependency.project_name, dist.requires())),
        }


packages = [transform(dist) for dist in pkg_resources.working_set.resolve(reqs)]
print(json.dumps(packages))
