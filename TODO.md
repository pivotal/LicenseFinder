# immediate
- Packages should log which licenses came from decisions. Maybe have
  Activations, which store a license and a source, which can be logged or
  otherwise manipulated.
- To make the core of LicenseFinder completely path independent, pass
  `project_path` to Core (for `project_name`) and from there to Configuration
  (for `saved_config`) and to PackageManagers (for `package_path`).

# architecture

# renamings, etc.

- classes under `package_managers` should be in a PackageManagers module
- `license_names_from_standard_spec` should be the default instance method

# docs

- specify gradle version >= 1.8
