
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

report --format
dependencies list --format
--who
--why
--when
