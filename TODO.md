
# immediate

- gradle and maven are broken
  - [x] let's refactor `PossibleLicenseFiles` to accept a nil install_path
  - [x] then remove `#licenses_from_files` from `{maven,gradle}_package.rb`
  - [x] update docs in package.rb to reflect what our expectations are.
- [x] commit the rest of the WIP


# architecture

- [x] package managers should use instance methods so we can inject things like loggers
- [ ] are we sprinkling database logic around too much? see 23f4cae for related work.


# renamings, etc.

- [x] retitle the shared example "it conforms to interface required by PackageSaver"
- [x] shared specs should go into a separate file(s)
- [ ] classes under `package_managers` should be in a PackageManagers module
- [ ] `license_names_from_standard_spec` should be the default instance method
- [ ] #groups in some Packages, #included_groups etc. in others


# docs

- [ ] specify gradle version >= 1.8

# immutable db

action_items
  read system dependencies
  include manually added dependencies
  apply manual licenses
  filter ignored dependencies
  filter ignored groups
  mark approved dependencies
  mark dependencies with whitelisted licenses
  output --format
  return deps.size

dependencies list
  include manually added dependencies
  apply manual licenses
  output --format

ignored_groups list
  list decisions

ignored_dependencies list
  list decisions

rescan
  remove

show_results
  remove

# DECISIONS

approve
  add decision

dependencies add
  add decision (dependency)
  add decision (license)
dependencies remove
  add decision

ignored_groups add
  add decision
ignored_groups remove
  add decision

ignored_dependencies add
  add decision
ignored_dependencies remove
  add decision

license
  add decision

whitelist add
  add decision
whitelist remove
  add decision
whitelist list
  list decisions

